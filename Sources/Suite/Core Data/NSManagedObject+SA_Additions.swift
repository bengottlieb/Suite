//
//  NSManagedObject+SA_Additions.swift
//  Suite
//
//  Created by Ben Gottlieb on 9/10/19.
//  Copyright (c) 2019 Stand Alone, Inc. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
	public class var didInsertNotification: Notification.Name { return Notification.Name("NSManagedObject_DidInsertNotification_\(self)") }
	public class var willDeleteNotification: Notification.Name { return Notification.Name("NSManagedObject_WillDeleteNotification_\(self)") }
	public class var didDeleteNotification: Notification.Name { return Notification.Name("NSManagedObject_DidDeleteNotification_\(self)") }

	public class func entityName(in moc: NSManagedObjectContext) -> String {
		let name = NSStringFromClass(self)

		for entity in moc.persistentStoreCoordinator?.managedObjectModel.entities ?? [] {
			if entity.managedObjectClassName == name, let entityName = entity.name { return entityName }
		}
		
		var trimmed = name.components(separatedBy: ".").last!
		if trimmed.hasSuffix("MO") { trimmed = String(trimmed[..<trimmed.index(trimmed.count - 2)]) }
		return trimmed
	}
}

extension NSManagedObject {
	open subscript(key: String) -> Any? {
		get { return self.value(forKey: key) }
		set { self.setValue(newValue, forKey: key) }
	}
	
	open var moc: NSManagedObjectContext? { return self.managedObjectContext }
	open func instantiate(in moc: NSManagedObjectContext) -> NSManagedObject? {
		return moc.object(with: self.objectID)
	}

	open func refreshInContext(merge: Bool = true) {
		self.managedObjectContext?.refresh(self, mergeChanges: merge)
	}

	open func save(wait: Bool = true, toDisk: Bool = true, completion: ((Error?) -> Void)? = nil) {
		self.managedObjectContext?.saveContext(wait: wait, toDisk: toDisk, completion: completion)
	}
	
	open func deleteFromContext(andSave: Bool = false) {
		let moc = self.moc
		type(of: self).willDeleteNotification.notify(self)
		let didDeleteNotification = type(of: self).didDeleteNotification
		self.managedObjectContext?.delete(self)

		if andSave, let moc = moc { moc.saveContext(wait: true, toDisk: true) }
		didDeleteNotification.notify()
	}
	
	open func hasProperty(key: String) -> Bool {
		let entity = self.entity
		
		if entity.attributesByName[key] != nil { return true }
		if entity.relationshipsByName[key] != nil { return true }
		return false
	}
}

extension NSManagedObject {
	open var threadsafeToken: ThreadsafeToken {
		return ThreadsafeToken(object: self)
	}
	
	open class ThreadsafeToken: NSObject {
		public let objectID: NSManagedObjectID
		
		init(object: NSManagedObject) {
			objectID = object.objectID
		}
	}
}

extension Array where Element: NSManagedObject {
	public var threadsafeTokens: [NSManagedObject.ThreadsafeToken] {
		return self.map { return $0.threadsafeToken }
	}
}

extension NSManagedObjectContext {
	open func reconstitute<T>(_ token: NSManagedObject.ThreadsafeToken?) -> T? {
		if let token = token {
			let objectID = token.objectID
			if let object = self.object(with: objectID) as? T { return object }
		}
		return nil
	}
	
	open func reconstitute<T>(record: T?) -> T? {
		if let record = record as? NSManagedObject {
			let objectID = record.objectID
			if let object = self.object(with: objectID) as? T { return object }
		}
		return nil
	}
	
	open func reconstitute<T>(_ tokens: [NSManagedObject.ThreadsafeToken]) -> [T] {
		var results: [T] = []
		for token in tokens {
			if let record: T = self.reconstitute(token) { results.append(record) }
		}
		return results
	}
}


