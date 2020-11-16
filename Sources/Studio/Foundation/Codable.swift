//
//  Codable+Additions.swift
//  Suite
//
//  Created by ben on 9/9/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import Foundation

public typealias JSONDictionary = [String: Any]

public protocol JSONExportable {
	func asJSON() throws -> JSONDictionary
}

extension Decodable {
	public static func load(from dictionary: JSONDictionary) throws -> Self {
		let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
		let decoder = JSONDecoder()
		return try decoder.decode(Self.self, from: data)
	}
}

extension Encodable {
	public func asJSON() throws -> JSONDictionary {
		let data = try asJSONData()
		return try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary ?? [:]
	}

	public func asJSONData() throws -> Data {
		try JSONEncoder().encode(self)
	}
	
	public func saveJSON(to url: URL) throws {
		let data = try JSONEncoder().encode(self)
		try data.write(to: url)
	}
	
	public func saveJSON(toUserDefaults key: String) throws {
		let data = try JSONEncoder().encode(self)
		UserDefaults.standard.set(data, forKey: key)
	}
	
	public func log(level: Logger.Level = .mild) {
		do {
			let data = try self.asJSONData()
			guard let raw = String(data: data, encoding: .utf8) else {
				Logger.instance.log("Unabled to encode \(self)")
				return
			}
			
			Logger.instance.log(raw.cleanedFromJSON, level: level)
		} catch {
			Logger.instance.log("Failed to encode \(self): \(error)", level: level)
		}
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

extension String {
	var cleanedFromJSON: String {
		return self.replacingOccurrences(of: "\\", with: "")
	}
}

public extension JSONEncoder {
	static var iso8601Encoder: JSONEncoder {
		let encoder = JSONEncoder()
		
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}
}

public extension JSONDecoder {
	static var iso8601Decoder: JSONDecoder {
		let decoder = JSONDecoder()
		
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}
}
