//
//  DefaultsValue.swift
//  
//
//  Created by Ben Gottlieb on 11/16/20.
//

import Foundation

@propertyWrapper
public struct DefaultsValue<T: Codable>: DynamicProperty {
	private let key: String
	private let defaultValue: T
	//@State private var current: T
	
	public init(key: String, defaultValue: T, in defaults: UserDefaults = .standard) {
		self.key = key
		self.defaultValue = defaultValue
		self.defaults = defaults
		//_current = State(initialValue: defaults.getCodable(for: key) ?? defaultValue)
	}
	
	let defaults: UserDefaults
	
	public var projectedValue: Binding<T> {
		Binding<T>(get: {
			wrappedValue
		}) { newValue in
			wrappedValue = newValue
		}
	}
	
	public var wrappedValue: T {
		get { defaults.getCodable(for: key) ?? defaultValue }
		nonmutating set {
		//	_current.wrappedValue = newValue
			defaults.setCodable(value: newValue, for: key)
		//	print(current)
		}
	}
}

private extension UserDefaults {
	func setCodable<T: Codable>(value: T, for key: String) {
		do {
			let data = try JSONEncoder().encode(value)
			set(data, forKey: key)
		} catch {
			Studio.logg(error: error, "Failed to encode DefaultsValue<\(T.self)>")
		}
	}
	func getCodable<T: Codable>(for key: String) -> T? {
		guard let data = data(forKey: key) else { return nil }
		do {
			return try JSONDecoder().decode(T.self, from: data)
		} catch {
			Studio.logg(error: error, "Failed to decode DefaultsValue<\(T.self)>")
			return nil
		}
	}
}
