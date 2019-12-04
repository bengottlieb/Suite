//
//  NSObject.swift
//  
//
//  Created by ben on 9/17/19.
//

import Foundation

public extension NSObject {
	func addAsObserver(for name: String, selector sel: Selector, object: Any? = nil) {
		self.addAsObserver(for: NSNotification.Name(name), selector: sel, object: object)
	}

	@nonobjc func addAsObserver(for name: NSNotification.Name, selector sel: Selector, object: Any? = nil) {
		if !self.responds(to: sel) {
			dlog("⚠️ Trying to register for a notification (\(name), but \(type(of: self)) doesn't respond to \(sel)")
			return
		}
		NotificationCenter.default.addObserver(self, selector: sel, name: name, object: object)
	}

	func removeAsObserver(forString notificationName: String) {
		self.removeAsObserver(for: NSNotification.Name(notificationName))
	}

	func removeAsObserver(for notificationName: NSNotification.Name? = nil) {
		if let name = notificationName {
			NotificationCenter.default.removeObserver(self, name: name, object: nil)
		} else {
			NotificationCenter.default.removeObserver(self)
		}
	}
}

public extension NSObject {
	func associate(object: Any?, forKey key: StaticString) {
		if let object: Any = object {
			objc_setAssociatedObject(self, key.utf8Start, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		} else {
			objc_setAssociatedObject(self, key.utf8Start, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	func associatedObject(forKey key: StaticString) -> Any? {
		return objc_getAssociatedObject(self, key.utf8Start)
	}
}

public extension NSObject {
	func replace(selector first: Selector, with second: Selector) {
		if let original = class_getInstanceMethod(type(of: self), first), let new = class_getInstanceMethod(type(of: self), second) {
			method_exchangeImplementations(original, new)
		}
	}
}
