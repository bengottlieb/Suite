import XCTest
@testable import Suite

final class SuiteTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Suite().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
