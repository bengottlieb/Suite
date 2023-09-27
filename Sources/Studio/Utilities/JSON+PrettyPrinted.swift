//
//  JSON+PrettyPrinted.swift
//  Suite
//
//  Created by Ben Gottlieb on 7/28/23.
//

import Foundation

@available(iOS 14.0, macOS 11, watchOS 8, *)
public extension Data {
	var prettyPrintedJSON: String? {
		self.jsonDictionary?.prettyPrinted
	}
}

@available(iOS 14.0, macOS 11, watchOS 8, *)
public extension String {
	var prettyPrintedJSON: String? {
		self.data(using: .utf8)?.jsonDictionary?.prettyPrinted
	}
}


@available(iOS 14.0, macOS 11, watchOS 8, *)
public extension Dictionary where Key == String {
	var prettyPrinted: String {
		prettyPrinted(prefix: "")
	}
	
	func prettyPrinted(prefix: String) -> String {
		if isEmpty { return "{}"}
		var result = "{\n"

		for (key, value) in self {
			result += prefix + "\t" + key + ": "
			
			if let int = value as? Int {
				result += "\(int)"
			} else if let string = value as? String {
				result += "\(string)"
			} else if let float = value as? Float {
				result += "\(float)"
			} else if let double = value as? Double {
				result += "\(double)"
			} else if let date = value as? Date {
				result += "\(date.localTimeString())"
			} else if let data = value as? Data {
				result += "\(data.hexString)"
			} else if let dict = value as? [String: Any] {
				result += dict.prettyPrinted(prefix: prefix + "\t")
			} else if let array = value as? [Any] {
				result += array.prettyPrinted(prefix: prefix + "\t")
			}
			
			result += ",\n"
		}
		
		return result + prefix + "}"
	}
}

@available(iOS 14.0, macOS 11, watchOS 8, *)
extension Array {
	func prettyPrinted(prefix: String) -> String {
		if isEmpty { return "[]"}
		var result = "[\n"
		
		for index in indices {
			let value = self[index]
			result += prefix + "\t" + "\(index): "
			
			if let int = value as? Int {
				result += "\(int)"
			} else if let string = value as? String {
				result += "\(string)"
			} else if let float = value as? Float {
				result += "\(float)"
			} else if let double = value as? Double {
				result += "\(double)"
			} else if let date = value as? Date {
				result += "\(date.localTimeString())"
			} else if let data = value as? Data {
				result += "\(data.hexString)"
			} else if let dict = value as? [String: Any] {
				result += dict.prettyPrinted(prefix: prefix + "\t")
			} else if let array = value as? [Any] {
				result += array.prettyPrinted(prefix: prefix + "\t")
			} else {
				result += "\(value)"
			}
			
			result += ",\n"
		}
		
		return result + prefix + "]"
	}

}
