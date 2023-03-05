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

public struct KeyDifferences {
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
			
			if value is Int, otherValue is Int { continue }
			if value is Double, otherValue is Double { continue }
			if value is String, otherValue is String { continue }
			if value is [Any], otherValue is [Any] { continue }
			if value is Float, otherValue is Float { continue }
			if value is Bool, otherValue is Bool { continue }

			if let myDict = value as? [String: Any], let otherDict = otherValue as? [String: Any] {
				let dictDiffs = myDict.diff(relativeTo: otherDict)
				diffs.append(dictDiffs, for: key)
				continue
			}

			diffs.changes.insert(key)
		}
		
		for key in otherKeys { diffs.additions.insert(key) }
		
		return diffs
	}
}
