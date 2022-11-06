//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 3/11/21.
//

import Foundation

/**
 Subclass this, then create all instance variables as
 @objc public dynamic var name: Type
 
 Note: in some cases, on macOS, the prefs daemon will get wedged, and you'll get console logs about being unable to read without entitlements.
 In this case, run the following in the terminal:
 
 ps auwx | grep cfprefsd | grep -v grep | awk '{print $2}' | xargs sudo kill -2
 */

@objc open class KeychainBasedPreferences: NSObject {
	public override init() {
		super.init()
		load()
	}
	
	public func refresh() {
		load()
	}
	
	open func key(from label: String?) -> String? {
		label
	}
	
	func load() {
		var mirror = Mirror(reflecting: self)
		
		while true {
			for child in mirror.children {
				guard let label = child.label, let key = key(from: child.label) else { continue }
				
				if let value: String = Keychain.instance.get(key) {
					self.setValue(value, forKey: label)
				} else if let value: Data = Keychain.instance.get(key) {
					self.setValue(value, forKey: label)
				}

				self.addObserver(self, forKeyPath: label, options: .new, context: nil)
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
		Keychain.instance.delete(key)
	}
	
	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		var mirror = Mirror(reflecting: self)
		while true {
			for child in mirror.children {
				guard let label = child.label, label == keyPath, let key = key(from: child.label) else { continue }
				
				let keychainKey = key
				let newValue = change?[.newKey]
				if let value = newValue as? String {
					Keychain.instance.set(value, forKey: keychainKey)
				} else if let value = newValue as? Data {
					Keychain.instance.set(value, forKey: keychainKey)
				} else {
					Keychain.instance.delete(keychainKey)
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
		return Notification.Name("KeychainBasedPreferences-\(key)")
	}
}
