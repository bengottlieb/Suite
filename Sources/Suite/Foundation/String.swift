//
//  String.swift
//  Suite
//
//  Created by Ben Gottlieb on 9/10/19.
//  Copyright (c) 2019 Stand Alone, Inc. All rights reserved.
//

import Foundation

public extension String {
	init?(data: Data?, encoding: String.Encoding = .ascii) {
		guard let data = data else { return nil }
		self.init(data: data, encoding: encoding)
	}
	
	init(_ lines: String...) {
		self = ""
		for (idx, item) in lines.enumerated() {
			self += "\(item)"
			if idx < lines.count - 1 {
				self += "\n"
			}
		}
	}
	
	var abbreviatingWithTildeInPath: String { return String(NSString(string: self).abbreviatingWithTildeInPath) }
	var expandingTildeInPath: String { return String(NSString(string: self).expandingTildeInPath) }

	static let OK = NSLocalizedString("OK", comment: "OK")
	static let Cancel = NSLocalizedString("Cancel", comment: "Cancel")
	
	subscript(i: Int) -> Character { return self[self.index(i)] }
	subscript(i: Int) -> String { return String(self[self.index(i)]) }
//	subscript(i: Int) -> Int { return Int(UnicodeScalar(self.characters[self.index(i)]).value) }
	subscript(range: Range<Int>) -> String { return String(self[self.index(range.lowerBound)..<self.index(range.upperBound)]) }

	func range(range: Range<Int>) -> Range<String.Index> { return self.index(range.lowerBound) ..< self.index(range.upperBound) }
	func range(range: NSRange) -> Range<String.Index> { return self.index(range.location) ..< self.index(range.location + range.length) }
	func index(_ index: Int) -> String.Index { return self.index(self.startIndex, offsetBy: min(index, self.count)) }
	var fullRange: Range<String.Index> { return self.range(range: NSRange(location: 0, length: self.count)) }
	
	var isValidEmail: Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
		
		let emailTest = NSPredicate(format: "SELF MATCHES %@", argumentArray: [emailRegEx])
		return emailTest.evaluate(with: self)
	}
	
	func stringByRemovingCharactersInSet(set: CharacterSet) -> String {
		var result = ""
		var count = 0
		
		for scalar in self.unicodeScalars {
			if !set.contains(scalar) {
				result += self[count]
			}
			count += 1
		}
		return result
	}
}

public func +(left: String?, right: String) -> String {
	return (left ?? "") + right
}

public func +(left: String, right: String?) -> String {
	return left + (right ?? "")
}

public func ==(left: String, right: String?) -> Bool {
	if right == nil { return false }
	return left == right!
}

public func ==(left: String?, right: String) -> Bool {
	if left == nil { return false }
	return left! == right
}

public extension String {
	static func randomEmoji(facesOnly: Bool = false) -> String {
		var range = [UInt32](0x1F601...0x1F64F)
		if !facesOnly { range += [UInt32](0x1F300...0x1F530) }
		let ascii = range.randomElement()!
		return UnicodeScalar(ascii)?.description ?? "🌈"
	}
}

public extension Array where Element == String {
	var sequenceString: String {
		guard !self.isEmpty else { return "" }
		var result = self.first!
		if self.count == 1 { return result }
		
		for string in self.dropFirst().dropLast() {
			result += ", " + string
		}
		
		result += " " + NSLocalizedString("and", comment: "and") + " " + self.last!
		return result
	}
}
