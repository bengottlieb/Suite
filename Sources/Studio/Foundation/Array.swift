//
//  Array.swift
//  
//
//  Created by ben on 9/17/19.
//

import Foundation

public extension Array where Element: Equatable {
	@discardableResult mutating func remove(_ object: Element) -> [Element] {
		if let index = self.firstIndex(of: object) {
			self.remove(at: index)
		}
		return self
	}
	
	@discardableResult mutating func toggle(_ item: Element) -> Self {
		if self.contains(item) {
			self.remove(item)
		} else {
			self.append(item)
		}
		
		return self
	}
}

extension Array: RawRepresentable where Element: RawRepresentable, Element.RawValue == String {
	public var rawValue: String { map { $0.rawValue }.joined(separator: ";") }
	
	public init?(rawValue: String) {
		let elem = rawValue.components(separatedBy: ";")
		self = elem.compactMap { Element(rawValue: $0) }
	}
}

public extension Array {
	func indicesMatching(where check: (Element) -> Bool) -> [Int] {
		indices.filter { check(self[$0]) }
	}

	func first(_ number: Int) -> [Element] {
		if number >= count { return self }
		
		return Array(self[0..<number])
	}

	func last(_ number: Int) -> [Element] {
		if number >= count { return self }
		
		return Array(self[count - number..<count])
	}
}

public extension Array where Element: Numeric {
	func sum() -> Element {
		var total: Element = 0
		
		for item in self { total += item }
		return total
	}
}

public extension Array where Element: BinaryFloatingPoint {
	func average() -> Element? {
		guard !isEmpty, let divisor = Element(exactly: count) else { return nil }
		return sum() / divisor
	}
}
public extension Array where Element: Equatable {
	func removingDuplicates() -> [Element] {
		guard let first = self.first else { return [] }
		
		var result = [first]
		
		for item in self {
			if !result.contains(item) { result.append(item) }
		}
		
		return result
	}
}

public extension Array where Element: Identifiable {
	subscript(elem: Element) -> Element? {
		get {
			guard let index = identifiableIndex(of: elem) else { return nil }
			return self[index]
		}
		
		set {
			guard let newValue else { return }
			if let index = identifiableIndex(of: elem) {
				self[index] = newValue
			} else {
				self.append(newValue)
			}
		}
	}
	
	func identifiableIndex(of elem: Element) -> Int? {
		firstIndex(where: { $0.id == elem.id })
	}
}

public extension Array {
	subscript(index index: Int?) -> Element? {
		guard let idx = index, idx < self.count else { return nil }
		return self[idx]
	}
	
	func breakIntoChunks(ofSize size: Int, growth: Double = 1.0) -> [[Element]] {
		if self.count <= size || size == 0 { return [self] }

		var chunkSize = size
		let count = self.count
		var start = chunkSize
		var results: [[Element]] = [Array(self[0..<chunkSize])]
		
		while (count - start) >= chunkSize {
			results.append(Array(self[start..<(start + chunkSize)]))
			start += chunkSize
			chunkSize = Int(Double(chunkSize) * growth)
		}
		
		
		if start < count {
			results.append(Array(self[start..<count]))
		}
		
		return results
	}
}

public extension Collection {
	func split<T: Equatable & Hashable>(by path: KeyPath<Element, T>) -> [[Element]] {
		var groups: [T: [Element]] = [:]
		
		for item in self {
			let key = item[keyPath: path]
			var set = groups[key] ?? []
			
			set.append(item)
			groups[key] = set
		}
		
		return groups.map { $0.1 }
	}
}

public extension Array where Element: Equatable {
	func removing(_ collection: [Element]) -> [Element] {
		self.filter { !collection.contains($0) }
	}
}
