//
//  NSManagedObject+JSON.swift
//  
//
//  Created by ben on 9/4/20.
//

import Foundation
import CoreData


public extension NSManagedObject {
	var dictionary: JSONDictionary {
		var results = JSONDictionary()
		
		for (name, attr) in self.entity.attributesByName {
			guard !attr.isStoredInExternalRecord, !attr.isTransient, let raw = self.value(forKey: name) else { continue }
			
			results[name] = raw
		}
		
		return results
	}
	
	func load(dictionary: JSONDictionary, combining: Bool = true) {
		for (name, _) in self.entity.attributesByName {
			if let raw = dictionary[name] {
				self.setPrimitiveValue(raw, forKey: name)
			} else if !combining {
				self.setPrimitiveValue(nil, forKey: name)
			}
		}
	}
}

extension NSAttributeDescription {
	var isPrimitive: Bool {
		self.attributeType != .transformableAttributeType
	}
}
