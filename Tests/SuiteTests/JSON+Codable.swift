//
//  JSON+Codable.swift
//  
//
//  Created by Ben Gottlieb on 6/24/23.
//

import XCTest
@testable import Studio

final class JSON_Codable: XCTestCase {
	struct TestCodable: Codable {
		enum CodingKeys: String, CodingKey { case json }
		var json: [String: Any] = ["kind": "Old friend", "count": 14, "nested": ["n1": "a", "n2": "b"], "items": [1, 3, 5, 7, 9, 3], "date": Date()]

		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			
			try container.encode(json, forKey: .json)
		}

		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			json = try container.decode([String: Any].self, forKey: .json)
		}
		
		init() { }
	}

    func testDictionaryCoding() throws {
		 let subject = TestCodable()
		 let data = try JSONEncoder().encode(subject)
		 let string = String(data: data, encoding: .utf8)!
		 let decoded = try JSONDecoder().decode(TestCodable.self, from: data)
		 
		 print(string)
		 print(decoded)
		 
		 XCTAssert(!data.isEmpty, "Shouldn't encode empty data")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
}
