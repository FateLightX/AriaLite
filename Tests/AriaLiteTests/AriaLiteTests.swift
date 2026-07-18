import Foundation
import XCTest
@testable import AriaLite

final class AppSettingsTests: XCTestCase {
    func testDefaults() {
        let settings = AppSettings()
        XCTAssertTrue(settings.autoConnectEngine)
        XCTAssertEqual(settings.downloadDirectory, "~/Downloads")
        XCTAssertEqual(settings.maxConcurrentDownloads, 5)
        XCTAssertEqual(settings.splitCount, 64)
        XCTAssertEqual(settings.maxConnectionsPerServer, 64)
        XCTAssertEqual(settings.downloadSpeedLimit, 0)
        XCTAssertEqual(settings.uploadSpeedLimit, 0)
        XCTAssertTrue(settings.showSpeedInMenuBar)
        XCTAssertTrue(settings.showMainWindowOnLaunch)
        XCTAssertTrue(settings.keepRunningAfterMainWindowClose)
        XCTAssertTrue(settings.hideDockIconInMenuBarMode)
        XCTAssertEqual(settings.rpcHost, "127.0.0.1")
        XCTAssertEqual(settings.rpcPort, 6800)
    }

    func testNormalizesRPCHost() {
        XCTAssertEqual(AppSettings.normalizedRPCHost("  "), "127.0.0.1")
        XCTAssertEqual(AppSettings.normalizedRPCHost(" 192.168.1.8 "), "192.168.1.8")
        XCTAssertTrue(AppSettings.isLocalRPCHost("127.0.0.1"))
        XCTAssertTrue(AppSettings.isLocalRPCHost("localhost"))
        XCTAssertTrue(AppSettings.isLocalRPCHost("::1"))
        XCTAssertFalse(AppSettings.isLocalRPCHost("192.168.1.8"))
    }

    func testDecodesEmptyJSONWithDefaults() throws {
        let settings = try JSONDecoder().decode(AppSettings.self, from: Data("{}".utf8))
        XCTAssertEqual(settings.rpcHost, "127.0.0.1")
        XCTAssertEqual(settings.rpcPort, 6800)
        XCTAssertEqual(settings.maxConcurrentDownloads, 5)
        XCTAssertEqual(settings.splitCount, 64)
    }

    func testDecodesRemoteRPCHost() throws {
        let data = Data(#"{"rpcHost":"10.0.0.5","rpcPort":16800}"#.utf8)
        let settings = try JSONDecoder().decode(AppSettings.self, from: data)
        XCTAssertEqual(settings.rpcHost, "10.0.0.5")
        XCTAssertEqual(settings.rpcPort, 16800)
    }

    func testClampsConcurrentDownloadsWhenDecoding() throws {
        let data = Data(#"{"maxConcurrentDownloads": 99}"#.utf8)
        let settings = try JSONDecoder().decode(AppSettings.self, from: data)
        XCTAssertEqual(settings.maxConcurrentDownloads, 10)
    }

    func testDecodesLegacyStringSpeedLimits() throws {
        let data = Data(#"{"downloadSpeedLimit":"12Mb/s","uploadSpeedLimit":"0"}"#.utf8)
        let settings = try JSONDecoder().decode(AppSettings.self, from: data)
        XCTAssertEqual(settings.downloadSpeedLimit, 12)
        XCTAssertEqual(settings.uploadSpeedLimit, 0)
    }
}

final class TaskModelTests: XCTestCase {
    func testFilterTitles() {
        XCTAssertEqual(TaskFilter.all.title, "全部")
        XCTAssertEqual(TaskFilter.active.title, "下载中")
        XCTAssertEqual(TaskFilter.waiting.title, "等待中")
        XCTAssertEqual(TaskFilter.complete.title, "已完成")
        XCTAssertEqual(TaskFilter.failed.title, "已失败")
    }

    func testStatusActions() {
        XCTAssertTrue(TaskStatus.active.canPause)
        XCTAssertFalse(TaskStatus.active.canResume)
        XCTAssertTrue(TaskStatus.paused.canResume)
        XCTAssertFalse(TaskStatus.paused.canPause)
        XCTAssertTrue(TaskStatus.waiting.canPause)
        XCTAssertTrue(TaskStatus.waiting.canResume)
        XCTAssertFalse(TaskStatus.complete.canPause)
        XCTAssertFalse(TaskStatus.failed.canResume)
    }

    func testSourceLink() {
        let withURL = DownloadTask(
            name: "a",
            status: .active,
            progress: 0.5,
            completedSize: "1 MB",
            totalSize: "2 MB",
            downloadSpeed: "1 MB/s",
            uploadSpeed: "0 B/s",
            remainingTime: "1s",
            savePath: "/tmp",
            gid: "1",
            errorMessage: nil,
            localFilePaths: [],
            sourceURLs: ["https://example.com/file.zip"],
            infoHash: "abc"
        )
        XCTAssertEqual(withURL.sourceLink, "https://example.com/file.zip")

        let magnetOnly = DownloadTask(
            name: "b",
            status: .waiting,
            progress: 0,
            completedSize: "0 B",
            totalSize: "0 B",
            downloadSpeed: "0 B/s",
            uploadSpeed: "0 B/s",
            remainingTime: "--",
            savePath: "/tmp",
            gid: "2",
            errorMessage: nil,
            localFilePaths: [],
            sourceURLs: [],
            infoHash: "deadbeef"
        )
        XCTAssertEqual(magnetOnly.sourceLink, "magnet:?xt=urn:btih:deadbeef")

        let empty = DownloadTask(
            name: "c",
            status: .failed,
            progress: 0,
            completedSize: "0 B",
            totalSize: "0 B",
            downloadSpeed: "0 B/s",
            uploadSpeed: "0 B/s",
            remainingTime: "--",
            savePath: "/tmp",
            gid: "3",
            errorMessage: "error",
            localFilePaths: [],
            sourceURLs: [],
            infoHash: nil
        )
        XCTAssertNil(empty.sourceLink)
    }
}

final class Aria2ClientTests: XCTestCase {
    func testLocalhostEndpoint() {
        let client = Aria2Client(port: 6800, token: "secret")
        XCTAssertEqual(client.endpoint.absoluteString, "http://127.0.0.1:6800/jsonrpc")
        XCTAssertEqual(client.token, "secret")
    }

    func testCustomHost() {
        let client = Aria2Client(host: "192.168.1.10", port: 6801)
        XCTAssertEqual(client.endpoint.absoluteString, "http://192.168.1.10:6801/jsonrpc")
    }
}
