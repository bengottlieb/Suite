//
//  UserDefaultsBackedDictionary.swift
//  
//
//  Created by Ben Gottlieb on 4/12/20.
//

import Foundation

public protocol UserDefaultStorable { }

extension String: UserDefaultStorable {}
extension Date: UserDefaultStorable {}
extension Data: UserDefaultStorable {}
extension Int: UserDefaultStorable {}
extension Double: UserDefaultStorable {}
extension URL: UserDefaultStorable {}
extension Float: UserDefaultStorable {}
extension Dictionary: UserDefaultStorable where Key == String, Value: UserDefaultStorable {}
extension Array: UserDefaultStorable where Element: UserDefaultStorable {}

public protocol StringConvertible {
	var string: String { get }
}

extension String: StringConvertible {
	public var string: String { return self }
}

public protocol KeyValueContainer {
	associatedtype Key: StringConvertible
	associatedtype Value: UserDefaultStorable
	
	subscript(key: Key) -> Value? { get set }
}

public struct UserDefaultsBackedDictionary<Key: StringConvertible, Value: UserDefaultStorable>: KeyValueContainer {
	let defaults: UserDefaults
	let converter: (Key) -> String
	
	public init(defaults: UserDefaults = .standard, converter: @escaping (Key) -> String = { key in key.string }) {
		self.defaults = defaults
		self.converter = converter
	}
	
	public func removeValue(forKey key: Key) {
		defaults.removeValue(forKey: string(from: key))
	}
	
	func string(from key: Key) -> String { return converter(key) }
	public subscript(key: Key) -> Value? {
		get { return defaults.value(forKey: string(from: key)) as? Value }
		set {
			if let value = newValue {
				self.defaults.set(value, forKey: string(from: key))
			} else {
				self.defaults.removeValue(forKey: string(from: key))
			}
		}
	}
}
