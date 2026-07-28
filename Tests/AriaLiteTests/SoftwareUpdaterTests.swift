import XCTest
@testable import AriaLite

final class SoftwareUpdaterTests: XCTestCase {
    func testComparesSemanticReleaseVersions() {
        XCTAssertTrue(SoftwareUpdater.isVersion("0.1.6", newerThan: "0.1.5"))
        XCTAssertTrue(SoftwareUpdater.isVersion("v1.0.0", newerThan: "0.9.9"))
        XCTAssertFalse(SoftwareUpdater.isVersion("0.1.5", newerThan: "0.1.5"))
        XCTAssertFalse(SoftwareUpdater.isVersion("0.1.4", newerThan: "0.1.5"))
    }
}
