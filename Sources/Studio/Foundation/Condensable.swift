//
//  Condensable.swift
//  
//
//  Created by Ben Gottlieb on 3/23/21.
//

import Foundation

public protocol Condensable {
	associatedtype Condensate: Codable
	
	func reconstitute(condensed: Condensate) throws
	var condensed: Condensate? { get }
	
}

public protocol Reconstitutable: Condensable {
	init(condensed: Condensate) throws
}

public extension Reconstitutable {
	init(payload: JSONDictionary) throws {
		let condensed = try Condensate.load(from: payload)
		try self.init(condensed: condensed)
	}
}

public extension Condensable {
	var payload: JSONDictionary? {
		guard let condensed = condensed else { return nil }
		do {
			return try condensed.asJSON()
		} catch {
			logg(error: error, "Failed to convert a \(Self.self)'s condensate to a JSONDictionary")
			return nil
		}
	}
	
	func load(payload: JSONDictionary) throws {
		let condensed = try Condensate.load(from: payload)
		try self.reconstitute(condensed: condensed)
	}
}
