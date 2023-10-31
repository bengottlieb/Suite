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

	func removingOccurrencesWords(of remove: [String], caseInsensitive: Bool = true) -> String {
		let components = components(separatedBy: .whitespacesAndNewlines)
		let removeThese = caseInsensitive ? remove.map { $0.lowercased() } : remove
		let results = components.filter { !(caseInsensitive ? removeThese.contains($0.lowercased()) : removeThese.contains($0)) }
		return results.joined(separator: " ")
	}

	func stripping(charactersIn set: CharacterSet) -> String {
		String(unicodeScalars.filter { !set.contains($0) })
	}
	
	var abbreviatingWithTildeInPath: String { return String(NSString(string: self).abbreviatingWithTildeInPath) }
	var expandingTildeInPath: String { return String(NSString(string: self).expandingTildeInPath) }

	static let OK = NSLocalizedString("OK", comment: "OK")
	static let Cancel = NSLocalizedString("Cancel", comment: "Cancel")
	
	subscript(i: Int) -> Character { return self[self.index(i)] }
	subscript(range: Range<Int>) -> String { return String(self[self.index(range.lowerBound)..<self.index(range.upperBound)]) }
	subscript(range: ClosedRange<Int>) -> String { return String(self[self.index(range.lowerBound)...self.index(range.upperBound)]) }
	subscript(range: PartialRangeUpTo<Int>) -> String { return String(self[self.startIndex..<self.index(range.upperBound)]) }
	subscript(range: PartialRangeFrom<Int>) -> String { return String(self[self.index(range.lowerBound)..<self.endIndex]) }

	func range(_ range: Range<Int>) -> Range<String.Index> { return self.index(range.lowerBound) ..< self.index(range.upperBound) }
	func range(_ range: NSRange) -> Range<String.Index> { return self.index(range.location) ..< self.index(range.location + range.length) }
	func index(_ index: Int) -> String.Index { return self.index(self.startIndex, offsetBy: min(index, self.count)) }
	var fullRange: Range<String.Index> { return self.range(NSRange(location: 0, length: self.count)) }
	
	func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
		 range(of: string, options: options)?.lowerBound
	}

	func position(of sub: String) -> Int? {
		if let index = index(of: sub) { return prefix(upTo: index).count }
		return nil
	}
	
	var numbersOnly: String {
		self.reduce("") { result, chr in
			"0123456789".contains(chr) ? result + String(chr) : result
		}
	}
	
	var pathExtension: String? {
		guard let ext = self.components(separatedBy: ".").last else { return nil }
		
		if ext.count < 10, !ext.isEmpty { return ext }
		return nil
	}
	
	var deletingFileExtension: String {
		guard let ext = self.pathExtension else { return self }
		
		let index = self.index(self.endIndex, offsetBy: -(ext.count + 2))
		return String(self[...index])
	}
	
	var isValidEmail: Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,50}"
		
		let emailTest = NSPredicate(format: "SELF MATCHES %@", argumentArray: [emailRegEx])
		return emailTest.evaluate(with: self)
	}
	
	var isValidPhoneNumber: Bool {
		 let types: NSTextCheckingResult.CheckingType = [.phoneNumber]
		 guard let detector = try? NSDataDetector(types: types.rawValue) else { return false }
		 if let match = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count)).first?.phoneNumber {
			  return match == self
		 } else {
			  return false
		 }
	}

	
	func stringByRemovingCharactersInSet(set: CharacterSet) -> String {
		var result = ""
		var count = 0
		
		for scalar in self.unicodeScalars {
			if !set.contains(scalar) {
				result += String(self[count])
			}
			count += 1
		}
		return result
	}
	
	static func entropicString(length: Int = 32) -> String {
		precondition(length > 0)
		let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
		var result = ""
		var remainingLength = length
		
		while remainingLength > 0 {
			let randoms: [UInt8] = (0 ..< 16).map { _ in
				var random: UInt8 = 0
				let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
				if errorCode != errSecSuccess {
					SuiteLogger.instance.log("Unable to generate random string. SecRandomCopyBytes failed with OSStatus \(errorCode)")
					return 0
				}
				return random
			}
			
			randoms.forEach { random in
				if remainingLength == 0 { return }
				
				if random < charset.count {
					result.append(charset[Int(random)])
					remainingLength -= 1
				}
			}
		}
		
		return result
	}
	
	func extractSubstring(start: String, end: String) -> String? {
		 guard let startIndex = self.range(of: start)?.upperBound,
				 let endIndex = self.range(of: end, range: startIndex..<string.endIndex)?.lowerBound
		 else {
			  return nil
		 }
		 
		 return String(string[startIndex..<endIndex])
	}


}

public extension String {
	static func randomEmoji(facesOnly: Bool = false) -> String {
		var range = [UInt32](0x1F601...0x1F64F)
		if !facesOnly { range += [UInt32](0x1F300...0x1F530) }
		let ascii = range.randomElement()!
		return UnicodeScalar(ascii)?.description ?? "🌈"
	}

	static func +(left: String?, right: String) -> String {
		return (left ?? "") + right
	}

	static func +(left: String, right: String?) -> String {
		return left + (right ?? "")
	}

	static func ==(left: String, right: String?) -> Bool {
		if right == nil { return false }
		return left == right!
	}

	static func ==(left: String?, right: String) -> Bool {
		if left == nil { return false }
		return left! == right
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

public extension Array where Element == String? {
	func concatenate(with separator: String, finalSeparator: String? = nil) -> String? {
		let collapsed = self.compactMap({ $0 })
		guard let first = collapsed.first else { return nil }
		
		if collapsed.count == 1 { return first }
		
		var result = first
		if collapsed.count > 2 {
			for i in collapsed.indices.dropFirst().dropLast() {
				result += separator + collapsed[i]
			}
		}
		result += (finalSeparator ?? separator) + collapsed.last!
		
		return result
	}
}
