//
//  URLSession.swift
//  
//
//  Created by Ben Gottlieb on 12/28/21.
//

import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension URLSession {
	public func data(for url: URL) async throws -> (Data, URLResponse) {
		try await data(for: URLRequest(url: url))
	}

	public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
		let result: (Data, URLResponse) = try await withCheckedThrowingContinuation { continuation in
			let task = dataTask(with: request) { data, response, error in
				if let err = error {
					continuation.resume(throwing: err)
				} else if let data = data, let resp = response {
					continuation.resume(returning: (data, resp))
				} else {
					continuation.resume(throwing: NSError())
				}
			}
			task.resume()
		}
		
		return result
	}
}
