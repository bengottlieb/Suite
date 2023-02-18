//
//  Date.swift
//  
//
//  Created by Ben Gottlieb on 2/18/23.
//

import XCTest
import Suite


final class DateTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
		 let date = Date()
		 let raw = date.rawValue
		 let newDate = Date(rawValue: raw)
		 
		 XCTAssert(newDate == date, "Failed to reconstitute a date")
	 }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
