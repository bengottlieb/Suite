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
	@State private var current: T
	private let storage: Storage

	public init(key: String, defaultValue: T, in defaults: UserDefaults = .standard) {
		self.key = key
		self.defaultValue = defaultValue
		self.defaults = defaults
		let initialValue = defaults.getCodable(for: key) ?? defaultValue
		storage = Storage(value: initialValue)
		_current = State(initialValue: initialValue)
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
		get {
			_ = _current.wrappedValue		// if we don't call this, it won't update in the SwiftUI world
			return storage.value }
		nonmutating set {
			_current.wrappedValue = newValue
			storage.value = newValue		// if we're not in a SwiftUI context, @State is useless
			defaults.setCodable(value: newValue, for: key)
		}
	}
	
	
	private class Storage {
		var value: T
		
		init(value: T) {
			self.value = value
		}
	}
}

private extension UserDefaults {
	func setCodable<T: Codable>(value: T, for key: String) {
		do {
			let data = try JSONEncoder.default.encode(value)
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
