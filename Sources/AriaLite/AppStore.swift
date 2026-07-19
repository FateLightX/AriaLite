import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    private static let maxRPCSecretLength = 128
    private static let rpcRestartDelay: Duration = .seconds(1)

    @Published var connectionState: ConnectionState = .stopped
    @Published var engineMessage = "下载引擎未连接"
    @Published var downloadSpeedText = "0 B/s"
    @Published var uploadSpeedText = "0 B/s"
    @Published var selectedFilter: TaskFilter = .all
    @Published var taskSearchText = ""
    @Published var taskSort: TaskSort = .status
    @Published var selectedTaskID: DownloadTask.ID?
    @Published var showAddTask = false
    @Published var showDeleteConfirmation = false
    @Published private(set) var rpcSecret = ""
    @Published private(set) var rpcPortNeedsRestart = false
    @Published var settings: AppSettings {
        didSet {
            LocalJSONStore.save(settings, to: LocalAppFiles.settingsURL)
        }
    }

    @Published var tasks: [DownloadTask] = []

    private var didAttemptAutomaticConnection = false
    private var pollingTask: Task<Void, Never>?
    private var pendingEngineRestartTask: Task<Void, Never>?
    private var consecutivePollFailures = 0
    @Published private(set) var taskListTruncated = false
    private let engineManager = EngineManager()
    private let notificationService = NotificationService()
    private var knownTaskStatuses: [String: TaskStatus] = [:]
    private var activeRPCHost: String?
    private var activeRPCPort: Int?
    private var activeRPCToken: String?

    init() {
        let loadedSettings = LocalJSONStore.load(AppSettings.self, from: LocalAppFiles.settingsURL)
        settings = loadedSettings ?? AppSettings()
        let storedRPCSecret = LocalSecretStore.load()
        rpcSecret = Self.normalizedRPCSecret(storedRPCSecret)
        if rpcSecret != storedRPCSecret {
            LocalSecretStore.save(rpcSecret)
        }
        activeRPCHost = AppSettings.normalizedRPCHost(settings.rpcHost)
        activeRPCPort = settings.rpcPort
        activeRPCToken = rpcSecret
        LoginItemService.removeLegacyLaunchAgent()
        if settings.autoConnectEngine {
            connectionState = .starting
            engineMessage = "正在连接 aria2 RPC"
        }
        notificationService.requestAuthorization()

        if loadedSettings == nil {
            LocalJSONStore.save(settings, to: LocalAppFiles.settingsURL)
        }
    }

    func openLoginItemSettings() {
        LoginItemService.openSystemSettings()
    }

    var selectedTask: DownloadTask? {
        guard let selectedTaskID else { return nil }
        return tasks.first { $0.id == selectedTaskID }
    }

    var filteredTasks: [DownloadTask] {
        let baseTasks: [DownloadTask] = switch selectedFilter {
        case .all:
            tasks
        case .active:
            tasks.filter { $0.status == .active }
        case .waiting:
            tasks.filter { $0.status == .waiting || $0.status == .paused }
        case .complete:
            tasks.filter { $0.status == .complete }
        case .failed:
            tasks.filter { $0.status == .failed }
        }

        let query = taskSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let searchedTasks = query.isEmpty ? baseTasks : baseTasks.filter {
            $0.name.lowercased().contains(query)
                || $0.savePath.lowercased().contains(query)
                || $0.gid.lowercased().contains(query)
        }

        return sortedTasks(searchedTasks)
    }

    var canPauseSelected: Bool {
        selectedTask?.status.canPause == true
    }

    var canResumeSelected: Bool {
        selectedTask?.status.canResume == true
    }

    var activeCount: Int { tasks.filter { $0.status == .active }.count }
    var waitingCount: Int { tasks.filter { $0.status == .waiting || $0.status == .paused }.count }
    var completeCount: Int { tasks.filter { $0.status == .complete }.count }
    var failedCount: Int { tasks.filter { $0.status == .failed }.count }

    func count(for filter: TaskFilter) -> Int {
        switch filter {
        case .all: tasks.count
        case .active: activeCount
        case .waiting: waitingCount
        case .complete: completeCount
        case .failed: failedCount
        }
    }

    func selectFilter(_ filter: TaskFilter) {
        selectedFilter = filter
        selectedTaskID = filteredTasks.first?.id
    }

    func pauseSelected() async {
        guard let selectedTask else { return }
        do {
            _ = try await makeClient().pause(gid: selectedTask.gid)
            await refreshTasksFromEngine()
        } catch {
            handleRPCError(error)
        }
    }

    func resumeSelected() async {
        guard let selectedTask else { return }
        do {
            _ = try await makeClient().unpause(gid: selectedTask.gid)
            await refreshTasksFromEngine()
        } catch {
            handleRPCError(error)
        }
    }

    func pauseAll() async {
        do {
            _ = try await makeClient().pauseAll()
            await refreshTasksFromEngine()
        } catch {
            handleRPCError(error)
        }
    }

    func resumeAll() async {
        do {
            _ = try await makeClient().unpauseAll()
            await refreshTasksFromEngine()
        } catch {
            handleRPCError(error)
        }
    }

    func startAutomaticConnectionIfNeeded() async {
        guard settings.autoConnectEngine, !didAttemptAutomaticConnection else { return }
        didAttemptAutomaticConnection = true
        await retryEngineConnection()
    }

    func retryEngineConnection() async {
        connectionState = .starting
        do {
            let client = makeClient()
            let version = try await connectOrStartEngine(client: client)
            try await refreshTasksFromEngine(using: client)
            engineMessage = "aria2 \(version.version) 已连接"
            connectionState = .connected
            startPolling()
        } catch {
            engineMessage = error.localizedDescription
            connectionState = .failed
            stopPolling()
        }
    }

    func stopEngine() {
        stopPolling()
        engineManager.stop()
        connectionState = .stopped
        engineMessage = "下载引擎已停止"
    }

    func stopEngineSavingSession() async {
        stopPolling()
        if connectionState == .connected {
            let client = makeClient()
            _ = try? await client.saveSession()
            // Only shut down engines we manage locally; never force-stop a remote RPC.
            if engineManager.isRunning {
                if (try? await client.forceShutdown()) != nil {
                    try? await waitForExternalEngineToStop(client: client)
                    try? await waitForManagedEngineToStop()
                }
            }
        }
        stopEngine()
    }

    func stopEngineForAppTermination() {
        stopPolling()
        pendingEngineRestartTask?.cancel()
        pendingEngineRestartTask = nil
        engineManager.stop()
        connectionState = .stopped
        engineMessage = "下载引擎已停止"
    }

    func restartEngineSavingSession() async {
        engineMessage = "正在重启 aria2 引擎"
        await stopEngineSavingSession()
        await retryEngineConnection()
        if connectionState == .connected {
            rpcPortNeedsRestart = false
        }
    }

    func restartEngineNowSavingSession() async {
        pendingEngineRestartTask?.cancel()
        pendingEngineRestartTask = nil
        await restartEngineSavingSession()
    }

    func saveSession() async {
        guard connectionState == .connected else { return }
        do {
            _ = try await makeClient().saveSession()
            engineMessage = "下载会话已保存"
        } catch {
            engineMessage = "保存下载会话失败：\(error.localizedDescription)"
        }
    }

    func clearStoppedResults() async {
        let removableTasks = tasks.filter { $0.status == .complete || $0.status == .failed }
        guard !removableTasks.isEmpty else { return }

        do {
            let client = makeClient()
            for task in removableTasks {
                _ = try await client.removeDownloadResult(gid: task.gid)
            }
            await refreshTasksFromEngine()
        } catch {
            handleRPCError(error)
        }
    }

    func refreshTasksFromEngine() async {
        await refreshTasksFromEngine(softFailure: false)
    }

    private func refreshTasksFromEngine(softFailure: Bool) async {
        do {
            try await refreshTasksFromEngine(using: makeClient())
            consecutivePollFailures = 0
            if connectionState != .connected {
                connectionState = .connected
            }
        } catch {
            engineMessage = error.localizedDescription
            if softFailure {
                consecutivePollFailures += 1
                if consecutivePollFailures >= 3 {
                    connectionState = .failed
                    stopPolling()
                }
            } else {
                connectionState = .failed
                stopPolling()
            }
        }
    }

    func deleteSelected(deleteFiles: Bool) async {
        guard let task = selectedTask else { return }
        do {
            let client = makeClient()
            if task.status == .complete || task.status == .failed {
                _ = try await client.removeDownloadResult(gid: task.gid)
            } else {
                _ = try await client.forceRemove(gid: task.gid)
            }

            if deleteFiles {
                _ = trashLocalFiles(for: task)
            }
            await refreshTasksFromEngine()
        } catch {
            handleRPCError(error)
        }
    }

    func setRPCHost(_ host: String) {
        let normalizedHost = AppSettings.normalizedRPCHost(host)
        guard settings.rpcHost != normalizedHost else { return }
        settings.rpcHost = normalizedHost
        rpcPortNeedsRestart = true
        engineMessage = AppSettings.isLocalRPCHost(normalizedHost)
            ? "RPC 地址已保存，正在重启引擎"
            : "RPC 地址已保存，正在重新连接"
        scheduleAutomaticEngineRestart()
    }

    func setRPCPort(_ port: Int) {
        let normalizedPort = min(max(port, 1), 65535)
        guard settings.rpcPort != normalizedPort else { return }
        settings.rpcPort = normalizedPort
        rpcPortNeedsRestart = true
        engineMessage = "RPC 端口已保存，正在重启引擎"
        scheduleAutomaticEngineRestart()
    }

    func setRPCSecret(_ secret: String, restartEngine: Bool = true) {
        let normalizedSecret = Self.normalizedRPCSecret(secret)
        guard rpcSecret != normalizedSecret else { return }
        rpcSecret = normalizedSecret
        LocalSecretStore.save(normalizedSecret)
        engineMessage = "RPC Secret 已保存，正在重启引擎"
        if restartEngine {
            scheduleAutomaticEngineRestart()
        }
    }

    func resetSettings() {
        setRPCSecret("", restartEngine: false)
        settings = AppSettings()
        activeRPCHost = AppSettings.normalizedRPCHost(settings.rpcHost)
        engineMessage = "设置已恢复默认值"
    }

    private func scheduleAutomaticEngineRestart() {
        pendingEngineRestartTask?.cancel()
        pendingEngineRestartTask = Task { [weak self] in
            do {
                try await Task.sleep(for: Self.rpcRestartDelay)
            } catch {
                return
            }

            guard let self, !Task.isCancelled else { return }
            self.pendingEngineRestartTask = nil
            await self.restartEngineSavingSession()
        }
    }

    private static func normalizedRPCSecret(_ secret: String) -> String {
        let bytes = secret.unicodeScalars.compactMap { scalar -> UInt8? in
            guard (33...126).contains(scalar.value) else { return nil }
            return UInt8(scalar.value)
        }
        return String(decoding: bytes.prefix(maxRPCSecretLength), as: UTF8.self)
    }

    func normalizeSettings() {
        settings.rpcHost = AppSettings.normalizedRPCHost(settings.rpcHost)
        settings.rpcPort = min(max(settings.rpcPort, 1), 65535)
        settings.maxConcurrentDownloads = min(max(settings.maxConcurrentDownloads, 1), 10)
        settings.splitCount = min(max(settings.splitCount, 1), 64)
        settings.maxConnectionsPerServer = min(max(settings.maxConnectionsPerServer, 1), 64)
        settings.downloadSpeedLimit = max(settings.downloadSpeedLimit, 0)
        settings.uploadSpeedLimit = max(settings.uploadSpeedLimit, 0)
    }

    private struct TrashResult {
        var total = 0
        var trashed = 0
        var missing = 0
        var failed = 0
        var lastError: String?
        var failedPaths: [String] = []
    }

    func deleteFileTargets(for task: DownloadTask) -> [String] {
        let rawPaths = task.localFilePaths
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let fallbackPaths = rawPaths.isEmpty ? [task.savePath] : rawPaths
        let expandedPaths = fallbackPaths
            .map { resolvedDeletePath($0, task: task) }
            .filter { !$0.isEmpty }

        return Array(Set(expandedPaths)).sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }

    func taskSummary(for task: DownloadTask) -> String {
        var lines = [
            "名称：\(task.name)",
            "GID：\(task.gid)",
            "状态：\(task.status.title)",
            "进度：\(Int((task.progress * 100).rounded()))%",
            "大小：\(task.completedSize) / \(task.totalSize)",
            "下载速度：\(task.downloadSpeed)",
            "上传速度：\(task.uploadSpeed)",
            "剩余时间：\(task.remainingTime)",
            "保存位置：\(task.savePath)"
        ]

        if let errorMessage = task.errorMessage {
            lines.append("错误：\(errorMessage)")
        }

        return lines.joined(separator: "\n")
    }

    private func trashLocalFiles(for task: DownloadTask) -> TrashResult {
        var result = TrashResult()
        for expandedPath in deleteFileTargets(for: task) {
            result.total += 1
            guard FileManager.default.fileExists(atPath: expandedPath) else {
                result.missing += 1
                continue
            }

            do {
                var trashedURL: NSURL?
                try FileManager.default.trashItem(at: URL(fileURLWithPath: expandedPath), resultingItemURL: &trashedURL)
                result.trashed += 1
            } catch {
                result.failed += 1
                result.failedPaths.append(expandedPath)
                result.lastError = error.localizedDescription
            }
        }

        if result.failed > 0 {
            let path = result.failedPaths.first.map { "：\($0)" } ?? ""
            engineMessage = "删除任务已完成，\(result.failed) 项未能移到废纸篓\(path)（\(result.lastError ?? "未知错误")）"
        }

        return result
    }

    private func resolvedDeletePath(_ path: String, task: DownloadTask) -> String {
        let expandedPath = (path as NSString).expandingTildeInPath
        guard !expandedPath.isEmpty else { return "" }
        guard !expandedPath.hasPrefix("/") else { return expandedPath }

        let expandedSavePath = (task.savePath as NSString).expandingTildeInPath
        guard !expandedSavePath.isEmpty else { return expandedPath }
        return URL(fileURLWithPath: expandedSavePath).appending(path: expandedPath).path
    }

    func addURLTask(urlText: String, fileName: String, splitCount: Int, downloadDirectory: String? = nil) async {
        let uris = urlText
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !uris.isEmpty else { return }

        var options = taskOptions(fileName: fileName, splitCount: splitCount, downloadDirectory: downloadDirectory)
        options["max-connection-per-server"] = "\(min(max(settings.maxConnectionsPerServer, 1), 64))"

        do {
            let client = makeClient()
            let gid = try await client.addUri(uris, options: options)
            selectedFilter = .all
            selectedTaskID = gid
            showAddTask = false
            await refreshTasksFromEngine()
        } catch {
            handleRPCError(error)
        }
    }

    func applyRuntimeDownloadSettings() async {
        guard connectionState == .connected else { return }

        do {
            _ = try await makeClient().changeGlobalOption([
                "max-concurrent-downloads": "\(min(max(settings.maxConcurrentDownloads, 1), 10))",
                "split": "\(min(max(settings.splitCount, 1), 64))",
                "max-connection-per-server": "\(min(max(settings.maxConnectionsPerServer, 1), 64))",
                "max-overall-download-limit": speedLimitOption(settings.downloadSpeedLimit) ?? "0",
                "max-overall-upload-limit": speedLimitOption(settings.uploadSpeedLimit) ?? "0"
            ])
        } catch {
            engineMessage = "设置已保存，但同步到 aria2 失败：\(error.localizedDescription)"
        }
    }

    private func refreshTasksFromEngine(using client: Aria2Client) async throws {
        async let globalStat = client.getGlobalStat()
        async let active = client.tellActive()
        async let waiting = fetchWaitingTasks(using: client)
        async let stopped = fetchStoppedTasks(using: client)

        let (stat, activeTasks, waitingResult, stoppedResult) = try await (globalStat, active, waiting, stopped)
        downloadSpeedText = Self.formatSpeed(stat.downloadSpeed)
        uploadSpeedText = Self.formatSpeed(stat.uploadSpeed)
        taskListTruncated = waitingResult.truncated || stoppedResult.truncated

        let previousSelection = selectedTaskID
        let refreshedTasks = (activeTasks + waitingResult.tasks + stoppedResult.tasks).map(Self.makeDownloadTask)
        notifyTaskChanges(refreshedTasks)
        tasks = refreshedTasks
        if let previousSelection, tasks.contains(where: { $0.id == previousSelection }) {
            selectedTaskID = previousSelection
        } else if previousSelection != nil {
            selectedTaskID = nil
        }
    }

    private static let taskPageSize = 100
    private static let maxTaskPages = 20

    private struct TaskPageResult {
        var tasks: [Aria2Task]
        var truncated: Bool
    }

    private func fetchWaitingTasks(using client: Aria2Client) async throws -> TaskPageResult {
        try await fetchPagedTasks { offset, count in
            try await client.tellWaiting(offset: offset, count: count)
        }
    }

    private func fetchStoppedTasks(using client: Aria2Client) async throws -> TaskPageResult {
        try await fetchPagedTasks { offset, count in
            try await client.tellStopped(offset: offset, count: count)
        }
    }

    private func fetchPagedTasks(
        _ loader: (Int, Int) async throws -> [Aria2Task]
    ) async throws -> TaskPageResult {
        var all: [Aria2Task] = []
        var offset = 0
        var truncated = false
        for page in 0..<Self.maxTaskPages {
            let batch = try await loader(offset, Self.taskPageSize)
            all.append(contentsOf: batch)
            if batch.count < Self.taskPageSize {
                return TaskPageResult(tasks: all, truncated: false)
            }
            offset += batch.count
            if page == Self.maxTaskPages - 1 {
                truncated = true
            }
        }
        return TaskPageResult(tasks: all, truncated: truncated)
    }

    static func makeDownloadTask(from task: Aria2Task) -> DownloadTask {
        let totalBytes = int64(task.totalLength)
        let completedBytes = int64(task.completedLength)
        let downloadSpeedBytes = int64(task.downloadSpeed)
        let uploadSpeedBytes = int64(task.uploadSpeed)
        let fileNames = task.files?.compactMap { fileName(from: $0.path) }.filter { !$0.isEmpty } ?? []
        let sourceURLs = task.files?.flatMap { $0.uris ?? [] }.map(\.uri).reduce(into: [String]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        } ?? []
        let name = task.bittorrent?.info?.name ?? fileNames.first ?? task.gid
        let status = makeTaskStatus(from: task.status)

        return DownloadTask(
            name: name,
            status: status,
            progress: totalBytes > 0 ? Double(completedBytes) / Double(totalBytes) : 0,
            completedSize: formatBytes(completedBytes),
            totalSize: formatBytes(totalBytes),
            downloadSpeed: formatSpeed(downloadSpeedBytes),
            uploadSpeed: formatSpeed(uploadSpeedBytes),
            remainingTime: remainingTime(total: totalBytes, completed: completedBytes, speed: downloadSpeedBytes, status: status),
            savePath: task.dir ?? "",
            gid: task.gid,
            errorMessage: task.errorMessage,
            localFilePaths: task.files?.map(\.path).filter { !$0.isEmpty } ?? [],
            sourceURLs: sourceURLs,
            infoHash: task.bittorrent?.infoHash
        )
    }

    static func protocolLabel(hasBitTorrent: Bool, sourceURLs: [String]) -> String {
        if hasBitTorrent { return "BT" }
        let uri = sourceURLs.first?.lowercased() ?? ""
        if uri.hasPrefix("magnet:") { return "Magnet" }
        if uri.hasPrefix("ed2k:") { return "ED2K" }
        if uri.hasPrefix("ftp:") || uri.hasPrefix("sftp:") { return "FTP" }
        if uri.hasPrefix("http://") || uri.hasPrefix("https://") { return "HTTP" }
        return "URL"
    }

    static func makeTaskStatus(from status: String) -> TaskStatus {
        switch status {
        case "active": .active
        case "waiting": .waiting
        case "paused": .paused
        case "complete": .complete
        case "error", "removed": .failed
        default: .waiting
        }
    }

    static func int64(_ value: String?) -> Int64 {
        Int64(value ?? "") ?? 0
    }

    static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    static func formatSpeed(_ bytesPerSecond: String?) -> String {
        formatSpeed(int64(bytesPerSecond))
    }

    static func formatSpeed(_ bytesPerSecond: Int64) -> String {
        "\(formatBytes(bytesPerSecond))/s"
    }

    static func remainingTime(total: Int64, completed: Int64, speed: Int64, status: TaskStatus) -> String {
        if status == .complete { return "已完成" }
        guard total > completed, speed > 0 else { return "--" }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval((total - completed) / speed)) ?? "--"
    }

    static func fileName(from path: String) -> String {
        URL(fileURLWithPath: path).lastPathComponent
    }

    private func connectOrStartEngine(client: Aria2Client) async throws -> Aria2Version {
        let host = AppSettings.normalizedRPCHost(settings.rpcHost)
        let isLocal = AppSettings.isLocalRPCHost(host)

        if engineManager.isRunning {
            if isLocal,
               activeRPCHost == host,
               activeRPCPort == settings.rpcPort,
               activeRPCToken == rpcSecret {
                return try await waitForEngine(client: client, requireManagedProcess: true)
            }

            engineMessage = "正在停止本地 aria2 引擎以应用新的 RPC 设置"
            _ = try? await client.saveSession()
            _ = try? await client.forceShutdown()
            try? await waitForExternalEngineToStop(client: client)
            try await waitForManagedEngineToStop()
            engineManager.stop()
        }

        activeRPCHost = host
        activeRPCPort = settings.rpcPort
        activeRPCToken = rpcSecret

        if !isLocal {
            engineMessage = "正在连接远程 aria2 RPC（\(host):\(settings.rpcPort)）"
            return try await waitForEngine(client: makeClient(), requireManagedProcess: false)
        }

        if let _ = try? await client.getVersion() {
            engineMessage = "正在重启旧 aria2 引擎以应用新设置"
            _ = try? await client.saveSession()
            _ = try await client.forceShutdown()
            try await waitForExternalEngineToStop(client: client)
            try await Task.sleep(for: .seconds(1))
        } else {
            let noSecretClient = Aria2Client(host: host, port: settings.rpcPort)
            if await noSecretClient.isReachable() {
                throw EngineManagerError.externalRPCInUse(settings.rpcPort)
            }
        }

        let launchClient = makeClient()
        engineMessage = "正在启动 aria2 引擎"
        try engineManager.startIfNeeded(settings: settings, rpcSecret: rpcSecret)
        return try await waitForEngine(client: launchClient, requireManagedProcess: true)
    }

    private func waitForEngine(client: Aria2Client, requireManagedProcess: Bool) async throws -> Aria2Version {
        var lastError: Error?
        for _ in 0..<20 {
            do {
                return try await client.getVersion()
            } catch {
                lastError = error
                if requireManagedProcess, !engineManager.isRunning {
                    throw EngineManagerError.processExited(engineManager.recentLogTail())
                }
                try await Task.sleep(for: .milliseconds(250))
            }
        }

        if requireManagedProcess {
            let logTail = engineManager.recentLogTail()
            if !logTail.isEmpty {
                throw EngineManagerError.rpcUnavailable(logTail)
            }
        }

        throw lastError ?? EngineManagerError.rpcUnavailable("无法连接 \(client.endpoint.host ?? "RPC"):\(client.endpoint.port ?? settings.rpcPort)")
    }

    private func waitForExternalEngineToStop(client: Aria2Client) async throws {
        for _ in 0..<24 {
            do {
                _ = try await client.getVersion()
            } catch {
                return
            }
            try await Task.sleep(for: .milliseconds(250))
        }

        throw EngineManagerError.rpcUnavailable("旧 aria2 引擎未释放 RPC 端口 \(settings.rpcPort)。")
    }

    private func waitForManagedEngineToStop() async throws {
        for _ in 0..<50 {
            if !engineManager.isRunning {
                return
            }
            try await Task.sleep(for: .milliseconds(100))
        }

        let port = activeRPCPort ?? settings.rpcPort
        throw EngineManagerError.rpcUnavailable("旧 aria2 引擎进程未完全退出，RPC 端口 \(port) 尚未释放。")
    }

    private func handleRPCError(_ error: Error) {
        engineMessage = error.localizedDescription
        guard !(error is Aria2RPCError) else { return }
        connectionState = .failed
        stopPolling()
    }

    private func notifyTaskChanges(_ refreshedTasks: [DownloadTask]) {
        defer {
            knownTaskStatuses = Dictionary(uniqueKeysWithValues: refreshedTasks.map { ($0.gid, $0.status) })
        }

        guard !knownTaskStatuses.isEmpty else { return }

        for task in refreshedTasks {
            let previousStatus = knownTaskStatuses[task.gid]
            guard previousStatus != task.status else { continue }

            if task.status == .complete {
                notificationService.send(title: "下载完成", body: task.name)
            } else if task.status == .failed {
                notificationService.send(title: "下载失败", body: task.name)
            }
        }
    }

    private func makeClient() -> Aria2Client {
        Aria2Client(
            host: activeRPCHost ?? AppSettings.normalizedRPCHost(settings.rpcHost),
            port: activeRPCPort ?? settings.rpcPort,
            token: activeRPCToken
        )
    }

    private func sortedTasks(_ tasks: [DownloadTask]) -> [DownloadTask] {
        switch taskSort {
        case .status:
            tasks.sorted { lhs, rhs in
                let lhsRank = statusRank(lhs.status)
                let rhsRank = statusRank(rhs.status)
                return lhsRank == rhsRank ? lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending : lhsRank < rhsRank
            }
        case .name:
            tasks.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .progress:
            tasks.sorted { $0.progress > $1.progress }
        }
    }

    private func statusRank(_ status: TaskStatus) -> Int {
        switch status {
        case .active: 0
        case .waiting: 1
        case .paused: 2
        case .failed: 3
        case .complete: 4
        }
    }

    private func taskOptions(fileName: String, splitCount: Int, downloadDirectory: String? = nil) -> [String: String] {
        let directory = resolvedDownloadDirectory(downloadDirectory)
        let normalizedSplitCount = min(max(splitCount, 1), 64)
        var options: [String: String] = [
            "dir": directory,
            "split": "\(normalizedSplitCount)"
        ]

        let trimmedFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedFileName.isEmpty {
            options["out"] = trimmedFileName
        }

        if let downloadLimit = speedLimitOption(settings.downloadSpeedLimit) {
            options["max-download-limit"] = downloadLimit
        }

        if let uploadLimit = speedLimitOption(settings.uploadSpeedLimit) {
            options["max-upload-limit"] = uploadLimit
        }

        return options
    }

    private func resolvedDownloadDirectory(_ downloadDirectory: String?) -> String {
        let trimmedDirectory = downloadDirectory?.trimmingCharacters(in: .whitespacesAndNewlines)
        let directory = trimmedDirectory?.isEmpty == false ? trimmedDirectory! : settings.downloadDirectory
        let expandedDirectory = (directory as NSString).expandingTildeInPath
        try? FileManager.default.createDirectory(atPath: expandedDirectory, withIntermediateDirectories: true)
        return expandedDirectory
    }

    private func speedLimitOption(_ value: Int) -> String? {
        value > 0 ? "\(value)M" : nil
    }

    private func startPolling() {
        pollingTask?.cancel()
        consecutivePollFailures = 0
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                let hasActive = await MainActor.run { (self?.activeCount ?? 0) > 0 }
                let seconds: Double = hasActive ? 2 : 5
                try? await Task.sleep(for: .seconds(seconds))
                guard !Task.isCancelled else { return }
                await self?.refreshTasksFromEngine(softFailure: true)
            }
        }
    }

    private func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
}
