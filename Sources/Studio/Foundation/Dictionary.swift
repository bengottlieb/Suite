//
//  Dictionary.swift
//  
//
//  Created by Ben Gottlieb on 7/4/20.
//

import Foundation

public extension Dictionary {
	@discardableResult
	mutating func addItems(from other: Dictionary) -> Self {
		for (key, value) in other {
			self[key] = value
		}
		return self
	}
}

public struct KeyDifferences: CustomStringConvertible {
	public var additions: Set<String> = []
	public var removals: Set<String> = []
	public var changes: Set<String> = []
	
	public var isEmpty: Bool { additions.isEmpty && removals.isEmpty && changes.isEmpty }
	public var count: Int { additions.count + removals.count + changes.count }
	
	mutating func append(_ diffs: KeyDifferences, for key: String) {
		additions = additions.union(diffs.additions.map { key + "." + $0 })
		removals = removals.union(diffs.removals.map { key + "." + $0 })
		changes = changes.union(diffs.changes.map { key + "." + $0 })
	}
	
	public var description: String {
		var result = ""
		if additions.isNotEmpty { result += "Added: \(additions.joined(separator: ", ")), " }
		if removals.isNotEmpty { result += "Removed: \(removals.joined(separator: ", ")), " }
		if changes.isNotEmpty { result += "Changed: \(changes.joined(separator: ", ")), " }
		return result
	}
}

extension Array {
	func isEqual(to other: [Any]) -> Bool {
		if other.count != count { return false }
		
		for i in 0..<count {
			if !ValuesAreEqual(self[i], other[i]) { return false }
		}
		return true
	}
}

public extension Dictionary where Key == String {
	func diff(relativeTo other: [String: Any]) -> KeyDifferences {
		var diffs = KeyDifferences()
		var otherKeys = Set(other.keys)
		
		for (key, value) in self {
			otherKeys.remove(key)
			guard let otherValue = other[key] else {
				diffs.additions.insert(key)
				continue
			}
			
			if ValuesAreEqual(value, otherValue) { continue }

			if let myDict = value as? [String: Any], let otherDict = otherValue as? [String: Any] {
				let dictDiffs = myDict.diff(relativeTo: otherDict)
				diffs.append(dictDiffs, for: key)
				continue
			}

			diffs.changes.insert(key)
		}
		
		for key in otherKeys { diffs.removals.insert(key) }
		
		return diffs
	}
}

func ValuesAreEqual(_ myValue: Any, _ theirValue: Any) -> Bool {
	if let mine = myValue as? Int, let theirs = theirValue as? Int, mine == theirs { return true }
	if let mine = myValue as? Double, let theirs = theirValue as? Double, mine == theirs { return true }
	if let mine = myValue as? String, let theirs = theirValue as? String, mine == theirs { return true }
	if let mine = myValue as? Float, let theirs = theirValue as? Float, mine == theirs { return true }
	if let mine = myValue as? Bool, let theirs = theirValue as? Bool, mine == theirs { return true }

	if let mine = myValue as? [Any], let theirs = theirValue as? [Any], mine.isEqual(to: theirs) { return true }
	if let myDict = myValue as? [String: Any], let otherDict = theirValue as? [String: Any] {
		if myDict.diff(relativeTo: otherDict).isEmpty { return true }
	}

	return false
}
