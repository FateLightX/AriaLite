import SwiftUI

enum ConnectionState: String, CaseIterable, Identifiable {
    case starting
    case connected
    case failed
    case stopped

    var id: String { rawValue }

    var title: String {
        switch self {
        case .starting: L10n.tr("正在连接")
        case .connected: L10n.tr("已连接")
        case .failed: L10n.tr("连接失败")
        case .stopped: L10n.tr("已停止")
        }
    }

    var detail: String {
        switch self {
        case .starting: L10n.tr("正在启动 aria2-next 引擎")
        case .connected: L10n.tr("aria2-next RPC 已连接")
        case .failed: L10n.tr("无法连接 aria2-next RPC")
        case .stopped: L10n.tr("下载引擎已停止")
        }
    }

    var color: Color {
        switch self {
        case .starting: .orange
        case .connected: .green
        case .failed: .red
        case .stopped: .secondary
        }
    }

    var symbol: String {
        switch self {
        case .starting: "hourglass"
        case .connected: "checkmark.circle.fill"
        case .failed: "wifi.slash"
        case .stopped: "stop.circle"
        }
    }
}

enum TaskFilter: String, CaseIterable, Identifiable {
    case all
    case active
    case waiting
    case complete
    case failed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: L10n.tr("全部")
        case .active: L10n.tr("下载中")
        case .waiting: L10n.tr("等待中")
        case .complete: L10n.tr("已完成")
        case .failed: L10n.tr("已失败")
        }
    }

    var symbol: String {
        switch self {
        case .all: "square.grid.2x2.fill"
        case .active: "arrow.down.circle.fill"
        case .waiting: "clock.fill"
        case .complete: "checkmark.circle.fill"
        case .failed: "xmark.circle.fill"
        }
    }
}

enum TaskStatus: String {
    case active
    case waiting
    case paused
    case complete
    case failed

    var title: String {
        switch self {
        case .active: L10n.tr("下载中")
        case .waiting: L10n.tr("等待中")
        case .paused: L10n.tr("已暂停")
        case .complete: L10n.tr("已完成")
        case .failed: L10n.tr("已失败")
        }
    }

    var color: Color {
        switch self {
        case .active: .blue
        case .waiting, .paused: .orange
        case .complete: .green
        case .failed: .red
        }
    }

    var canPause: Bool {
        self == .active || self == .waiting
    }

    var canResume: Bool {
        self == .paused || self == .waiting
    }
}

enum TaskSort: String, CaseIterable, Identifiable {
    case status
    case name
    case progress

    var id: String { rawValue }

    var title: String {
        switch self {
        case .status: L10n.tr("状态")
        case .name: L10n.tr("名称")
        case .progress: L10n.tr("进度")
        }
    }
}

struct DownloadTask: Identifiable, Hashable {
    var name: String
    var status: TaskStatus
    var progress: Double
    var completedSize: String
    var totalSize: String
    var downloadSpeed: String
    var uploadSpeed: String
    var remainingTime: String
    var savePath: String
    var gid: String
    var errorMessage: String?
    var localFilePaths: [String]
    var sourceURLs: [String]
    var infoHash: String?

    var id: String { gid }

    var sourceLink: String? {
        if let sourceURL = sourceURLs.first {
            return sourceURL
        }
        if let infoHash, !infoHash.isEmpty {
            return "magnet:?xt=urn:btih:\(infoHash)"
        }
        return nil
    }
}
