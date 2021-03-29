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

extension Encodable {
	var stringValue: String? {
		stringValue(from: JSONEncoder())
	}
	
	func stringValue(from encoder: JSONEncoder) -> String? {
		guard let data = try? encoder.encode(self) else { return nil }
		
		return String(data: data, encoding: .utf8)
	}

	public func asJSON() throws -> JSONDictionary {
		let data = try asJSONData()
		return try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary ?? [:]
	}

	public func asJSONData(using encoder: JSONEncoder = .init()) throws -> Data {
		try encoder.encode(self)
	}
	
	public func saveJSON(to url: URL, using encoder: JSONEncoder = .init()) throws {
		let data = try encoder.encode(self)
		try data.write(to: url)
	}
	
	public func saveJSON(toUserDefaults key: String, using encoder: JSONEncoder = .init()) throws {
		let data = try encoder.encode(self)
		UserDefaults.standard.set(data, forKey: key)
	}
	
	public func logg(level: Logger.Level = .mild) {
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
	public static func load(fromJSONData data: Data, using decoder: JSONDecoder = .init()) throws -> Self {
		return try decoder.decode(self, from: data)
	}
	
	public static func loadJSON(from url: URL, using decoder: JSONDecoder = .init()) throws -> Self {
		let data = try Data(contentsOf: url)
		return try self.load(fromJSONData: data, using: decoder)
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

@available(iOS 10.0, *)
public extension JSONEncoder {
	static var iso8601Encoder: JSONEncoder {
		let encoder = JSONEncoder()
		
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}
}

@available(iOS 10.0, *)
public extension JSONDecoder {
	enum DecodingError: Error { case unknownKey(String) }

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
