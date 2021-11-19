//
//  ImageTests.swift
//  
//
//  Created by Ben Gottlieb on 11/19/21.
//

import XCTest
import Suite

class ImageTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testResizing() throws {
        let landscape = CGRect(x: 0, y: 0, width: 1024, height: 768)
        let portrait = CGRect(x: 0, y: 0, width: 768, height: 1024)
        let square = CGRect(x: 0, y: 0, width: 300, height: 300)
        
        let horizontalLetterboxing = landscape.within(limit: square, placed: .scaleAspectFit)
        let verticalLetterboxing = portrait.within(limit: square, placed: .scaleAspectFit)

        XCTAssert(horizontalLetterboxing.width == square.width && horizontalLetterboxing.aspectRatio == landscape.aspectRatio, "Failed to resize a landscape into a square")

        XCTAssert(verticalLetterboxing.height == square.height && verticalLetterboxing.aspectRatio == portrait.aspectRatio, "Failed to resize a portrait into a square")

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
