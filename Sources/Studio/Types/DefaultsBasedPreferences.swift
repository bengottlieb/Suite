//
//  DefaultsBasedPreferences.swift
//  Suite
//
//  Created by Ben Gottlieb on 9/9/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import Foundation

public protocol PreferencesKeyProvider: AnyObject {
	var keys: [String: String] { get }
}

/**
	Subclass this, then create all instance variables as
		@objc public dynamic var name: Type

	Note: in some cases, on macOS, the prefs daemon will get wedged, and you'll get console logs about being unable to read without entitlements.
	In this case, run the following in the terminal:

		ps auwx | grep cfprefsd | grep -v grep | awk '{print $2}' | xargs sudo kill -2
*/

@objc open class DefaultsBasedPreferences: NSObject {
	public override init() {
		super.init()
		
		load()
	}

	
	public func refresh() {
		load()
	}

	public func save() {
		self.defaults.synchronize()
	}
	
	func load() {
		let defaults = self.defaults
		var mirror = Mirror(reflecting: self)
		
		while true {
			for child in mirror.children {
				guard let key = child.label else { continue }
				
				if let value = defaults.object(forKey: self.name(forKey: key)) {
					self.setValue(value, forKey: key)
				}
				self.addObserver(self, forKeyPath: key, options: .new, context: nil)
			}
			guard let sup = mirror.superclassMirror else { break }
			mirror = sup
		}
	}
	
	deinit {
		for child in Mirror(reflecting: self).children {
			guard let key = child.label else { continue }
			self.removeObserver(self, forKeyPath: key)
		}
	}
	
	open func clearValue(forKey key: String) {
		self.defaults.removeObject(forKey: key)
	}
	
	open func name(forKey key: String) -> String {
		if let provider = self as? PreferencesKeyProvider, let name = provider.keys[key] {
			return name
		}
		return key
	}
	
	public func hasValue(forKey key: String) -> Bool {
		return self.defaults.hasValueForKey(key: self.name(forKey: key))
	}
	
	open var defaults: UserDefaults { return UserDefaults.standard }
	weak var saveTimer: Timer?
	
	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		var mirror = Mirror(reflecting: self)
		while true {
			for child in mirror.children {
				guard let key = child.label, key == keyPath else { continue }
				
				let defaultsKey = self.name(forKey: key)
				if let value = change?[.newKey], !(value is NSNull) {
					self.defaults.set(value, forKey: defaultsKey)
				} else {
					self.defaults.removeValue(forKey: defaultsKey)
				}
				DispatchQueue.main.async {
					self.saveTimer?.invalidate()
					if #available(iOS 10.0, *) {
						self.saveTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
							self.defaults.synchronize()
						}
					} else {
						fatalError("observeValue not available pre-iOS 10")
					}
				}
				Notification.postOnMainThread(name: self.notificationName(forKey: key))
				return
			}

			guard let sup = mirror.superclassMirror else { break }
			mirror = sup
		}
		
		super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
	}
	
	open func notificationName(forKey key: String) -> Notification.Name {
		return Notification.Name("DefaultsBasedPreferences-\(key)")
	}
}

public extension UserDefaults {
	func hasValueForKey(key: String) -> Bool {
		return self.object(forKey: key) != nil
	}
	
	func removeValue(forKey key: String) {
		self.removeObject(forKey: key)
	}
	
	func clearValue(forKey key: String) {
		self.removeValue(forKey: key)
	}
}
