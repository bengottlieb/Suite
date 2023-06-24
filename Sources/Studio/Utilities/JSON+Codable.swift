//
//  JSON+Codable.swift
//
//
//  Created by Ben Gottlieb on 6/24/23.
//

import Foundation
import CloudKit

extension KeyedDecodingContainer {
	public func decode(_ type: [String: Any].Type, forKey key: Self.Key) throws -> [String: Any] {
		var values = try self.decode([String: Any?].self, forKey: key)
		
		for (key, value) in values {
			if value == nil { values.removeValue(forKey: key) }
		}
		return values as [String: Any]
	}
	
	public func decode(_ type: [String: Any?].Type, forKey key: Self.Key) throws -> [String: Any?] {
		let container = try nestedContainer(keyedBy: StringCodingKey.self, forKey: key)
		
		var result: [String: Any] = [:]
		
		for nestedKey in container.allKeys {
			if let int = try? container.decode(Int.self, forKey: nestedKey) {
				result[nestedKey.stringValue] = int
			} else if let string = try? container.decode(String.self, forKey: nestedKey) {
				result[nestedKey.stringValue] = string
			} else if let float = try? container.decode(Float.self, forKey: nestedKey) {
				result[nestedKey.stringValue] = float
			} else if let double = try? container.decode(Double.self, forKey: nestedKey) {
				result[nestedKey.stringValue] = double
			} else if let date = try? container.decode(EncodedDate.self, forKey: nestedKey) {
				result[nestedKey.stringValue] = date.date
			} else if let data = try? container.decode(EncodedData.self, forKey: nestedKey) {
				result[nestedKey.stringValue] = data.data
			} else if let array = try? container.decode(EncodedArray.self, forKey: nestedKey) {
				result[nestedKey.stringValue] = array.array
			} else if let dict = try? container.decode(EncodedDictionary.self, forKey: nestedKey) {
				result[nestedKey.stringValue] = dict.dictionary
			} else {
				result[nestedKey.stringValue] = nil
			}
		}
		
		return result
	}

	public func decode(_ type: [Any].Type, forKey key: Self.Key) throws -> [Any] {
		var container = try nestedUnkeyedContainer(forKey: key)
		var result: [Any] = []
		
		while !container.isAtEnd {
			if let int = try? container.decode(Int.self) {
				result.append(int)
			} else if let string = try? container.decode(String.self) {
				result.append(string)
			} else if let float = try? container.decode(Float.self) {
				result.append(float)
			} else if let double = try? container.decode(Double.self) {
				result.append(double)
			} else if let date = try? container.decode(EncodedDate.self) {
				result.append(date.date)
			} else if let data = try? container.decode(EncodedData.self) {
				result.append(data.data)
			} else if let dict = try? container.decode(EncodedDictionary.self) {
				result.append(dict.dictionary)
			} else if let array = try? container.decode(EncodedArray.self) {
				result.append(array.array)
			}
		}
		
		return result
	}

}

extension KeyedEncodingContainer {
	public mutating func encode(_ dictionary: [String: Any], forKey key: K) throws {
		try encode(dictionary as [String: Any?], forKey: key)
	}
	
	public mutating func encode(_ dictionary: [String: Any?], forKey key: K) throws {
		var container = nestedContainer(keyedBy: StringCodingKey.self, forKey: key)
		for key in dictionary.keys.sorted() {
			let codedKey = StringCodingKey(key)
			let value = dictionary[key]
			
			if let int = value as? Int {
				try container.encode(int, forKey: codedKey)
			} else if let string = value as? String {
				try container.encode(string, forKey: codedKey)
			} else if let float = value as? Float {
				try container.encode(float, forKey: codedKey)
			} else if let double = value as? Double {
				try container.encode(double, forKey: codedKey)
			} else if let date = value as? Date {
				try container.encode(EncodedDate(date: date), forKey: codedKey)
			} else if let data = value as? Data {
				try container.encode(EncodedData(data: data), forKey: codedKey)
			} else if let dict = value as? [String: Any] {
				try container.encode(EncodedDictionary(dict), forKey: codedKey)
			} else if let array = value as? [Any] {
				try container.encode(EncodedArray(array), forKey: codedKey)
			}
		}
		
	}
	
	public mutating func encode(_ array: [Any], forKey key: K) throws {
		var container = nestedUnkeyedContainer(forKey: key)
		
		for index in array.indices {
			let value = array[index]
			
			if let int = value as? Int {
				try container.encode(int)
			} else if let string = value as? String {
				try container.encode(string)
			} else if let float = value as? Float {
				try container.encode(float)
			} else if let double = value as? Double {
				try container.encode(double)
			} else if let date = value as? Date {
				try container.encode(date.timeIntervalSince1970)
			} else if let data = value as? Data {
				try container.encode(data.base64EncodedString())
			} else if let dict = value as? [String: Any] {
				try container.encode(EncodedDictionary(dict))
			} else if let array = value as? [Any] {
				try container.encode(EncodedArray(array))
			}
		}
	}
}

fileprivate struct StringCodingKey: CodingKey, Equatable, Comparable {
	let key: String
	init(_ key: String) { self.key = key }
	var stringValue: String { key }
	init?(stringValue: String) { key = stringValue }
	init?(intValue: Int) { return nil }
	var intValue: Int? { nil }
	
	static func <(lhs: Self, rhs: Self) -> Bool { lhs.stringValue < rhs.stringValue }
}

fileprivate struct IntCodingKey: CodingKey, Comparable, Equatable {
	let index: Int
	init(_ index: Int) { self.index = index }
	var stringValue: String { "\(index)" }
	init?(stringValue: String) { return nil }
	init?(intValue: Int) { index = intValue }
	var intValue: Int? { index }
	
	static func <(lhs: Self, rhs: Self) -> Bool { lhs.intValue! < rhs.intValue! }
}

fileprivate struct EncodedDate: Codable { let date: Date }
fileprivate struct EncodedData: Codable { let data: Data }
fileprivate struct EncodedDictionary: Codable {
	let dictionary: [String: Any]
	enum CodingKeys: String, CodingKey { case dictionary }
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(dictionary, forKey: .dictionary)
	}
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		dictionary = try container.decode([String: Any].self, forKey: .dictionary)
	}
	init(_ dict: [String: Any]) { dictionary = dict }
	
}
fileprivate struct EncodedArray: Codable {
	let array: [Any]
	enum CodingKeys: String, CodingKey { case array }
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(array, forKey: .array)
	}
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		array = try container.decode([Any].self, forKey: .array)
	}
	init(_ arr: [Any]) { array = arr }
	
}
