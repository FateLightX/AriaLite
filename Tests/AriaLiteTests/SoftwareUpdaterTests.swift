import XCTest
@testable import AriaLite

final class SoftwareUpdaterTests: XCTestCase {
    func testComparesSemanticReleaseVersions() {
        XCTAssertTrue(SoftwareUpdater.isVersion("1.2.0", newerThan: "1.1.9"))
        XCTAssertTrue(SoftwareUpdater.isVersion("v2.0.0", newerThan: "1.9.9"))
        XCTAssertFalse(SoftwareUpdater.isVersion("1.2.0", newerThan: "1.2.0"))
        XCTAssertFalse(SoftwareUpdater.isVersion("1.1.9", newerThan: "1.2.0"))
    }
}
