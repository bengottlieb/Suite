//
//  NSManagedObject+JSON.swift
//  
//
//  Created by ben on 9/4/20.
//

import Foundation
import CoreData


@available(iOS 11.0, *)
public extension NSManagedObject {
	func dictionary(dateStrategy: JSONEncoder.DateEncodingStrategy? = .default) -> JSONDictionary {
		var results = JSONDictionary()
		
		for (name, attr) in self.entity.attributesByName {
			guard !attr.isTransient, let raw = self.value(forKey: name) else { continue }
			
			if let strategy = dateStrategy, attr.attributeType == .dateAttributeType, let date = raw as? Date {
				if let value = strategy.jsonValue(from: date) {
					results[name] = value
				}
            } else if attr.attributeType == .booleanAttributeType {
                results[name] = (raw as? Int) == 1
            } else {
				results[name] = raw
			}
		}
		
		return results
	}
	
	func load<Object: Encodable>(from object: Object, dateStrategy: JSONEncoder.DateEncodingStrategy = .default) throws {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = dateStrategy
		let data = try object.asJSONData(using: encoder)
		
		guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary else { return }
		self.load(dictionary: dictionary)
	}
	
	func load(dictionary: JSONDictionary, combining: Bool = true, dateStrategy: JSONDecoder.DateDecodingStrategy = .default) {
		for (name, attr) in self.entity.attributesByName {
			var value = dictionary[name]
			
			if attr.attributeType == .dateAttributeType {
				value = dateStrategy.date(from: value)
			} else if attr.attributeType == .URIAttributeType {
				value = URL(string: value as? String ?? "")
			}
			if let raw = value {
				self.setValue(raw, forKey: name)
			} else if !combining {
				self.setValue(nil, forKey: name)
			}
		}
	}
    
    func build<Object: Decodable>(dateStrategy: JSONDecoder.DateDecodingStrategy = .default) throws -> Object {
        let dictionary = self.dictionary(dateStrategy: dateStrategy.encodingStrategy)
        let rawJSON = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateStrategy
        return try decoder.decode(Object.self, from: rawJSON)
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

