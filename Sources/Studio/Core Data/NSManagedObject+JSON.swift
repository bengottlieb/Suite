//
//  NSManagedObject+JSON.swift
//  
//
//  Created by ben on 9/4/20.
//

import Foundation
import CoreData


public extension NSManagedObject {
	func dictionary(dateStrategy: JSONEncoder.DateEncodingStrategy? = .default) -> JSONDictionary {
		var results = JSONDictionary()
		
		for (name, attr) in self.entity.attributesByName {
			guard !attr.isStoredInExternalRecord, !attr.isTransient, let raw = self.value(forKey: name) else { continue }
			
			if let strategy = dateStrategy, attr.attributeType == .dateAttributeType, let date = raw as? Date {
				if let value = strategy.jsonValue(from: date) {
					results[name] = value
				}
			} else {
				results[name] = raw
			}
		}
		
		return results
	}
	
	func load(dictionary: JSONDictionary, combining: Bool = true, dateStrategy: JSONDecoder.DateDecodingStrategy = .default) {
		for (name, attr) in self.entity.attributesByName {
			var value = dictionary[name]
			
			if attr.attributeType == .dateAttributeType {
				value = dateStrategy.date(from: value)
			}
			if let raw = value {
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

public extension JSONEncoder.DateEncodingStrategy {
	static var `default` = JSONEncoder.DateEncodingStrategy.formatted(DateFormatter.defaultJSONFormatter)
	
	func jsonValue(from date: Date) -> Any? {
		switch self {
		case .formatted(let formatter): return formatter.string(from: date)
		case .iso8601: return DateFormatter.iso8601.string(from: date)
		case .millisecondsSince1970: return date.timeIntervalSince1970 * 1000.0
		case .secondsSince1970: return date.timeIntervalSince1970
		default: break
		}
		return nil
	}
}

public extension JSONDecoder.DateDecodingStrategy {
	static var `default` = JSONDecoder.DateDecodingStrategy.formatted(DateFormatter.defaultJSONFormatter)
	
	func date(from something: Any?) -> Date? {
		switch self {
		case .formatted(let formatter):
			guard let string = something as? String else { return nil }
			return formatter.date(from: string)
			
		case .iso8601:
			guard let string = something as? String else { return nil }
			return DateFormatter.iso8601.date(from: string)
		
		case .millisecondsSince1970:
			guard let secs = something as? TimeInterval else { return nil }
			return Date(timeIntervalSince1970: secs / 1000.0)
			
		case .secondsSince1970:
			guard let secs = something as? TimeInterval else { return nil }
			return Date(timeIntervalSince1970: secs)
		default: break
		}
		return nil
	}
}

