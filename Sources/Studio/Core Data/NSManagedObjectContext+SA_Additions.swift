//
//  NSManagedObjectContext+SA_Additions.swift
//  Suite
//
//  Created by Ben Gottlieb on 9/10/19.
//  Copyright (c) 2019 Stand Alone, Inc. All rights reserved.
//

import Foundation
import CoreData



public extension NSManagedObjectContext {
	var isEmpty: Bool {
		guard let names = persistentStoreCoordinator?.managedObjectModel.entitiesByName.keys else { return true }
		for name in names {
			if self.count(of: name) > 0 { return false }
		}
		return true
	}

	func encapsulate<T: NSManagedObject>(_ object: T, perform: @escaping (T) -> Void) {
		self.perform {
			if let obj = self.instantiate(object) {
				perform(obj)
			}
		}
	}
	
	func perform(block: @escaping (NSManagedObjectContext) -> Void) {
		self.perform { block(self) }
	}
	
	func insertEntity(named name: String) -> NSManagedObject {
		let result = NSEntityDescription.insertNewObject(forEntityName: name, into: self) as NSManagedObject
		type(of: result).didInsertNotification.notify(self)
		return result
	}
	
	@objc func registerForExternalChangeUpdates() {
		self.addAsObserver(of: .NSManagedObjectContextDidSave, selector: #selector(mergeChanges(fromContextDidSave:)))
	}
	
	func count(of entityName: String, matching predicate: NSPredicate? = nil) -> Int {
		let request = self.generateFetchRequest(for: entityName)
		request.predicate = predicate
		
		do {
			let count = try self.count(for: request)
			return count
		} catch let error {
			logg(error: error, "Counting fetch request for \(entityName)")
		}
		return 0
	}
	
	@objc func saveContext(wait: Bool = true, toDisk: Bool = false, ignoreHasChanges: Bool = false, completion: (ErrorCallback)? = nil) {
		let context: NSManagedObjectContext? = self
		var saveError: Error?
		
		if !self.hasChanges { return }
		let block = {
			do {
				if let ctx = context, (ctx.hasChanges || toDisk), let psc = ctx.persistentStoreCoordinator?.persistentStores, psc.count > 0 {
					try ctx.save()
				} else {
					completion?(saveError)
					return
				}
				
				if toDisk {
					context?.parent?.saveContext(wait: true, toDisk: true)
				}
			} catch let error {
				logg(error: error, "Saving context")
				saveError = error
			}
			completion?(saveError)
		}
		
		if wait {
			self.performAndWait(block)
		} else {
			self.perform(block)
		}
	}
	
	func refreshAllFaults() {
		let faults = self.registeredObjects.filter { $0.isFault }
		
		faults.forEach { self.refresh($0, mergeChanges: true) }
	}

	func generateFetchRequest(for name: String) -> NSFetchRequest<NSFetchRequestResult> {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
		
		return request
	}

	func instantiate<T: NSManagedObject>(_ object: T?) -> T? {
		guard let obj = object else { return nil }
		return self.object(with: obj.objectID) as? T
	}
	
	func insertObject(named entityName: String) -> NSManagedObject? {
		let result = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self)
		type(of: result).didInsertNotification.notify(self)
		return result
	}
	
	func insertObject<T>(entity: T.Type) -> T? where T: NSManagedObject {
		let entityName = T.entityName(in: self)
		return self.insertObject(named: entityName) as? T
	}
	
	@available(iOS 11.0, *)
	func insertObject<T>(loading dictionary: JSONDictionary? = nil, dateStrategy: JSONDecoder.DateDecodingStrategy = .default) -> T! where T: NSManagedObject {
		let entityName = T.entityName(in: self)
		let entity = self.insertObject(named: entityName) as? T
		if let dict = dictionary { entity?.load(dictionary: dict, combining: false, dateStrategy: dateStrategy) }
		return entity
	}
	
	func fetchAll<T>(matching predicate: NSPredicate? = nil, sortedBy: [NSSortDescriptor] = []) -> [T] where T: NSManagedObject {
		return self.fetchAll(named: T.entityName(in: self), matching: predicate, sortedBy: sortedBy) as? [T] ?? []
	}
	
	func fetchAll(named entityName: String, matching predicate: NSPredicate? = nil, sortedBy: [NSSortDescriptor] = []) -> [NSManagedObject] {
		let request = self.generateFetchRequest(for: entityName)
		if predicate != nil { request.predicate = predicate! }
		if sortedBy.count > 0 { request.sortDescriptors = sortedBy }
		
		do {
			if let results = try self.fetch(request) as? [NSManagedObject] {
				return results
			}
		} catch let error {
			logg(error: error, "Executing fetch request: \(request)")
		}
		return []
	}
	
	func fetchAny<T>(matching predicate: NSPredicate? = nil, sortedBy sortBy: [NSSortDescriptor] = []) -> T? where T: NSManagedObject {
		return self.fetchAny(named: T.entityName(in: self), matching: predicate, sortedBy: sortBy) as? T
	}
	
	func fetchAny(named entityName: String, matching predicate: NSPredicate? = nil, sortedBy sortBy: [NSSortDescriptor] = []) -> NSManagedObject? {
		if sortBy.count == 0 {
			for object in self.registeredObjects where !object.isFault && object.entity.name == entityName {
				if predicate == nil || predicate!.evaluate(with: object) { return object }
			}
		}
		
		let request = self.generateFetchRequest(for: entityName)
		if predicate != nil { request.predicate = predicate! }
		request.fetchLimit = 1
		if sortBy.count > 0 { request.sortDescriptors = sortBy }
		
		do {
			if let results = try self.fetch(request) as? [NSManagedObject] {
				guard let record = results.first else { return nil }
				if let pred = predicate {
					return pred.evaluate(with: record) ? record : nil
				}
				return record
			}
		} catch let error {
			logg(error: error, "Executing fetch request: \(request)")
		}
		
		return nil
	}
	
    @discardableResult func deleteObjects(named entityName: String, matching predicate: NSPredicate = NSPredicate(value: true), singleRecord: Bool = false) throws -> Bool {
		let fetchRequest = self.generateFetchRequest(for: entityName)
		fetchRequest.predicate = predicate
		if singleRecord { fetchRequest.fetchLimit = 1 }
	
		if let records = try self.fetch(fetchRequest) as? [NSManagedObject], records.count > 0 {
			for record in records {
				self.delete(record)
			}
			return true
		}
		
		return false
	}
	
	func fetch(fields: [String], from entityName: String, matching predicate: NSPredicate? = nil) -> [[String: Any]] {
		let request = self.generateFetchRequest(for: entityName)
		if predicate != nil { request.predicate = predicate! }
		
		request.resultType = .dictionaryResultType
		request.propertiesToFetch = fields
		do {
			if let results = try self.fetch(request) as? [[String: Any]] {
				return results
			}
		} catch {}
		return []
	}
	
	func fetch(field: String, from entityName: String, matching predicate: NSPredicate? = nil) -> [Any] {
		return self.fetch(fields: [field], from: entityName, matching: predicate).compactMap { $0[field] }
	}

}
