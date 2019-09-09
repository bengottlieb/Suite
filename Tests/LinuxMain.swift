import XCTest

import SuiteTests

var tests = [XCTestCaseEntry]()
tests += SuiteTests.allTests()
XCTMain(tests)
