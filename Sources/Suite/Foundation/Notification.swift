//
//  Notification.swift
//  Suite
//
//  Created by Ben Gottlieb on 9/9/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import Foundation

public protocol Notifier: RawRepresentable { }

public extension Notifier {
	var notificationName: Notification.Name { return Notification.Name("\(self.rawValue)") }
	func notify(object: Any? = nil, info: NSDictionary? = nil) {
		self.notificationName.notify(object, info: info, forceCurrentThread: false)
	}
}

public extension NSObject {
	func addAsObserver<Note: Notifier>(of note: Note, selector sel: Selector, object: Any? = nil) {
		NotificationCenter.default.addObserver(self, selector: sel, name: note.notificationName, object: object)
	}
}

public extension Notification.Name {
	func watch(_ object: Any, message: Selector) {
		NotificationCenter.default.addObserver(object, selector: message, name: self, object: nil)
	}

	func unwatch(_ observer: Any, object: Any? = nil) {
		NotificationCenter.default.removeObserver(observer, name: self, object: object)
	}
	
	func notify(_ object: Any? = nil, info: NSDictionary? = nil, forceCurrentThread: Bool = false) {
		if forceCurrentThread {
			Notification.post(name: self, object: object, userInfo: info)
		} else {
			Notification.postOnMainThread(name: self, object: object, userInfo: info)
		}
	}
}

public extension Notification {
	static func post(name: String, object: Any? = nil, userInfo: NSDictionary? = nil) {
		self.post(name: Notification.Name(rawValue: name), object: object, userInfo: userInfo)
	}
	
	static func post(name: Notification.Name, object: Any? = nil, userInfo: NSDictionary? = nil) {
		NotificationCenter.default.post(name: name, object: object, userInfo: userInfo as? [String: Any])
	}
	
	static func postOnMainThread(name: String, object: Any? = nil, userInfo: NSDictionary? = nil) {
		self.postOnMainThread(name: Notification.Name(rawValue: name), object: object, userInfo: userInfo)
	}

	static func postOnMainThread(name: Notification.Name, object: Any? = nil, userInfo: NSDictionary? = nil) {
		DispatchQueue.main.async {
			self.post(name: name, object: object, userInfo: userInfo)
		}
	}

	class Observation {
		var token: NSObjectProtocol?
		
		deinit {
			if let token = self.token {
				NotificationCenter.default.removeObserver(token)
			}
		}
		
		init(name: String, object: NSObject? = nil, oneOff: Bool = false, queue: OperationQueue? = nil, block: @escaping (Notification) -> Void) {
			self.token = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: name), object: object, queue: queue, using: { [weak self] note in
				block(note as Notification)
				
				if oneOff, let token = self?.token {
					NotificationCenter.default.removeObserver(token)
				}
			})
		}
	}
}
