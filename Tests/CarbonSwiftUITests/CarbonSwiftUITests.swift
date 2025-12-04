import XCTest
@testable import CarbonSwiftUI

final class CarbonSwiftUITests: XCTestCase {
    func testVersion() throws {
        XCTAssertEqual(CarbonSwiftUI.version, "1.0.0")
    }
}
