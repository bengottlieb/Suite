//
//  DefaultsValue.swift
//  
//
//  Created by Ben Gottlieb on 11/16/20.
//

import Foundation

@propertyWrapper
public struct DefaultsValue<T> {
	private let key: String
	private let defaultValue: T?
	
	public init(key: String, defaultValue: T? = nil, in defaults: UserDefaults = .standard) {
		self.key = key
		self.defaultValue = defaultValue
		self.defaults = defaults
	}
	
	let defaults: UserDefaults
	
	public var wrappedValue: T? {
		get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
		set {
			if let value = newValue {
				defaults.set(value, forKey: key)
			} else {
				defaults.removeValue(forKey: key)
			}
		}
	}
}
