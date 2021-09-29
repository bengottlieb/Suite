//
//  URLResponse.swift
//  
//
//  Created by Ben Gottlieb on 9/29/21.
//

import Foundation

public extension URLResponse {
	var isSuccessfulHTTPResponse: Bool {
		guard let http = self as? HTTPURLResponse else { return false }
		
		return http.statusCode.isSuccessfulHTTPResponse
	}
	

}

public extension Int {
	var isSuccessfulHTTPResponse: Bool {
		self / 100 == 2
	}

	var isServerErrorHTTPResponse: Bool {
		self / 100 == 5
	}
}
