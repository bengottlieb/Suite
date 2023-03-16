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
	
	func testTimeRangeIntersections() {
		let start = Date.TimeRange(.init(hour: 9, minute: 30), .init(hour: 11, minute: 30))
		let end = Date.TimeRange(.init(hour: 10, minute: 0), .init(hour: 13, minute: 0))
		let otherEnd = Date.TimeRange(.init(hour: 16, minute: 0), .init(hour: 17, minute: 0))

		let intersection = start.intersection(with: end)
		XCTAssert(intersection == Date.TimeRange(.init(hour: 10, minute: 0), .init(hour: 11, minute: 30)), "\(start) should intersect with \(end)")

		let badIntersection = start.intersection(with: otherEnd)
		XCTAssert(badIntersection == nil, "\(start) shouldn't intersect with \(otherEnd)")
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
