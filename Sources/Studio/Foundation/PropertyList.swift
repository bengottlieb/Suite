//
//  PropertyList.swift
//  
//
//  Created by Ben Gottlieb on 3/28/21.
//

import Foundation

public typealias PropertyListDictionary = Dictionary<String, PropertyListDataType>
public protocol PropertyListDataType { }

extension String: PropertyListDataType { }
extension Int: PropertyListDataType { }
extension Double: PropertyListDataType { }
extension URL: PropertyListDataType { }
extension Date: PropertyListDataType { }
extension Data: PropertyListDataType { }
extension Dictionary: PropertyListDataType where Key == String, Value: PropertyListDataType { }
extension Array: PropertyListDataType where Element: PropertyListDataType { }

extension Dictionary where Key == String {
	public var plist: PropertyListDictionary { self as? PropertyListDictionary ?? [:] }
}

extension PropertyListDictionary {
	public var jsonDictionary: JSONDictionary {
		compactMapValues { value in
			value as? JSONDataType
		}
	}
}

extension JSONDictionary {
	public var propertyListDictionary: PropertyListDictionary {
		compactMapValues { value in
			value as? PropertyListDataType
		}
	}
}

public func PropertyListItem(_ any: Any?) -> PropertyListDataType? {
	(any as Any) as? PropertyListDataType
}

public extension Data {
	var propertyList: PropertyListDictionary? {
		var format: PropertyListSerialization.PropertyListFormat = .binary
		guard let result = try? PropertyListSerialization.propertyList(from: self, format: &format) else { return nil }
		
		if let prop = result as? PropertyListDictionary { return prop }
		if let json = result as? JSONDictionary { return json.propertyListDictionary }
		return nil
	}
}

