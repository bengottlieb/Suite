//
//  DictionaryTests.swift
//  
//
//  Created by Ben Gottlieb on 3/5/23.
//

import XCTest

final class DictionaryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
		 let dict1: [String: Any] = ["A": 1, "B": "c", "C": ["1": 3]]
		 let dict2: [String: Any] = ["A": 1, "B": "c", "C": ["1": 3]]
		 let dict3: [String: Any] = ["A": "1", "B": "c", "C": ["1", 3]]
		 let dict4: [String: Any] = ["A": 1, "B": "c", "C": ["1": "a"], "D": 4]

		 let diff1To2 = dict1.diff(relativeTo: dict2)
		 let diff1To3 = dict1.diff(relativeTo: dict3)
		 let diff1To4 = dict1.diff(relativeTo: dict4)

		 XCTAssert(diff1To2.isEmpty, "Dict1 and Dict2 should be the same")
		 XCTAssert(diff1To3.count == 2, "Dict1 to Dict3 should have 2 changes")
		 XCTAssert(diff1To4.count == 2, "Dict1 to Dict3 should have 2 changes")

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
