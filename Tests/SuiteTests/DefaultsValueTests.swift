//
//  DefaultsValueTests.swift
//  
//
//  Created by Ben Gottlieb on 12/16/22.
//

import XCTest
@testable import Suite

final class DefaultsValueTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	
	
	func testInNotSwiftUIEnvironment() throws {
		let initialValue = Int.random(in: 0...10000)
		let newValue = Int.random(in: 0...10000)
		let value = DefaultsState(key: "test_key", defaultValue: initialValue)
		
		value.wrappedValue = newValue
		XCTAssert(value.wrappedValue == newValue)
	}
	
	func testPerformanceExample() throws {
	}
	
}
