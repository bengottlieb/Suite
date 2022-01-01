//
//  Condensable.swift
//  
//
//  Created by Ben Gottlieb on 3/23/21.
//

import Foundation

public protocol CondensableCondensate: Codable {
	var version: Int { get set }
}

public protocol Condensable {
	associatedtype Condensate: CondensableCondensate
	
	func reconstitute(condensed: Condensate) throws
	var condensed: Condensate? { get }
	
}

public protocol Reconstitutable: Condensable {
	init(condensed: Condensate) throws
}

public extension Reconstitutable {
	init(payload: JSONDictionary) throws {
		let condensed = try Condensate.loadJSON(dictionary: payload)
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
		let condensed = try Condensate.loadJSON(dictionary: payload)
		if let version = self.condensed?.version, version >= condensed.version { return }
		try self.reconstitute(condensed: condensed)
	}
}
