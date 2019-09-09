//
//  Codable+Additions.swift
//  Suite
//
//  Created by ben on 9/9/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import Foundation

extension Encodable {
	public var asJSONData: Data? {
		return try? JSONEncoder().encode(self)
	}
	
	public func saveJSON(to url: URL) throws {
		let data = try JSONEncoder().encode(self)
		try data.write(to: url)
	}
	
	public func saveJSON(toUserDefaults key: String) throws {
		let data = try JSONEncoder().encode(self)
		UserDefaults.standard.set(data, forKey: key)
	}
}

extension Decodable {
	public static func load(fromJSONData data: Data) throws -> Self {
		return try JSONDecoder().decode(self, from: data)
	}
	
	public static func loadJSON(from url: URL) throws -> Self {
		let data = try Data(contentsOf: url)
		return try self.load(fromJSONData: data)
	}
	
	public static func loadJSON(fromUserDefaults key: String) throws -> Self {
		let data = UserDefaults.standard.data(forKey: key) ?? Data()
		return try self.load(fromJSONData: data)
	}
}
