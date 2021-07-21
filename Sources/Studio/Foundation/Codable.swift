//
//  Codable+Additions.swift
//  Suite
//
//  Created by ben on 9/9/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import Foundation

public protocol JSONDataType: Codable { }

extension String: JSONDataType { }
extension Int: JSONDataType { }
extension Double: JSONDataType { }
extension Date: JSONDataType { }
extension Data: JSONDataType { }
extension Dictionary: JSONDataType where Key == String, Value: JSONDataType { }
extension Array: JSONDataType where Element: JSONDataType { }

public typealias JSONDictionary = [String: Any]

public extension JSONDictionary {
	var plist: PropertyListDictionary { self as? PropertyListDictionary ?? [:] }
}

extension Dictionary where Key == String {
	public var jsonDictionary: JSONDictionary {
		self.compactMapValues { value in
			value as? JSONDataType
		}
	}
}

public protocol JSONExportable {
	func asJSON() throws -> JSONDictionary
}

public protocol PostDecodeAwakable: AnyObject {
	func awakeFromDecoder()
}

extension Decodable {
	public static func load(from dictionary: JSONDictionary, using decoder: JSONDecoder = JSONExpandedDecoder()) throws -> Self {
		let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
		return try decoder.decode(Self.self, from: data)
	}
}

public class JSONExpandedDecoder: JSONDecoder {
	open override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
		let result = try super.decode(type, from: data)
		
		if let awakable = result as? PostDecodeAwakable {
			awakable.awakeFromDecoder()
		}
		return result
	}
}

public extension Encodable {
	var stringValue: String? {
		stringValue(from: JSONEncoder())
	}
	
	func stringValue(from encoder: JSONEncoder) -> String? {
		guard let data = try? encoder.encode(self) else { return nil }
		
		return String(data: data, encoding: .utf8)
	}

	func asJSON(using encoder: JSONEncoder = .default) throws -> JSONDictionary {
		let data = try asJSONData(using: encoder)
		return try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary ?? [:]
	}

	func asJSONData(using encoder: JSONEncoder = .default) throws -> Data {
		try encoder.encode(self)
	}
	
	func saveJSON(to url: URL, using encoder: JSONEncoder = .default) throws {
		let data = try encoder.encode(self)
		try data.write(to: url)
	}
	
	func saveJSON(toUserDefaults key: String, using encoder: JSONEncoder = .default) throws {
		let data = try encoder.encode(self)
		UserDefaults.standard.set(data, forKey: key)
	}
	
	func logg(level: Logger.Level = .mild) {
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
	public static func loadJSON(data: Data?, using decoder: JSONDecoder = .default) throws -> Self {
		guard let data = data else { throw JSONDecoder.DecodingError.fileNotFound }
		return try decoder.decode(self, from: data)
	}
	
	public static func loadJSON(file url: URL?, using decoder: JSONDecoder = .default) throws -> Self {
		guard let url = url else { throw JSONDecoder.DecodingError.fileNotFound }
		let data = try Data(contentsOf: url)
		return try self.loadJSON(data: data, using: decoder)
	}
	
	public static func loadJSON(userDefaults key: String) throws -> Self {
		let data = UserDefaults.standard.data(forKey: key)
		return try self.loadJSON(data: data)
	}
	
	@available(iOS 10.0, *)
	public static func load(fromString string: String, using decoder: JSONDecoder = .default) throws -> Self {
		guard let data = string.data(using: .utf8) else { throw JSONDecoder.DecodingError.badString }
		
		return try decoder.decode(Self.self, from: data)
	}
}

extension String {
	var cleanedFromJSON: String {
		return self.replacingOccurrences(of: "\\", with: "")
	}
}

public extension JSONEncoder {
	static var `default` = JSONEncoder()
}

@available(iOS 10.0, *)
public extension JSONEncoder {
	static var iso8601Encoder: JSONEncoder {
		let encoder = JSONEncoder()
		
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}
}

public extension JSONDecoder {
	static var `default` = JSONDecoder()

	enum DecodingError: Error { case unknownKey(String), badString, jsonDecodeFailed, fileNotFound }
}

@available(iOS 10.0, *)
public extension JSONDecoder {
	static var iso8601Decoder: JSONDecoder {
		let decoder = JSONExpandedDecoder()
		
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}
}

@available(iOS 10.0, *)
public extension Encodable where Self: Decodable {
	func duplicate(using encoder: JSONEncoder = .iso8601Encoder, and decoder: JSONDecoder = .iso8601Decoder) throws -> Self {
		let data = try encoder.encode(self)
		return try decoder.decode(Self.self, from: data)
	}
}

public extension Decodable where Self: Encodable {
	func copyViaJSON(usingEncoder encoder: JSONEncoder = .default, decoder: JSONDecoder = .default) throws -> Self {
		let data = try encoder.encode(self)
		let result = try decoder.decode(Self.self, from: data)
		
		(result as? PostDecodeAwakable)?.awakeFromDecoder()
		
		return result
	}
}
