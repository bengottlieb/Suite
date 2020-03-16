//
//  ThreadsafeCollections.swift
//
//  Created by Ben Gottlieb on 3/16/19.
//

import Foundation

public struct ThreadsafeArrayGenerator<Element>: IteratorProtocol {
	let array: ThreadsafeArray<Element>
	var index = 0
	
	public mutating func next() -> Element? {
		if index >= self.array.count { return nil }
		let value: Element? = self.array[index]
		index += 1
		return value
	}
	
	init(_ a: ThreadsafeArray<Element>) {
		array = a
	}
}

extension ThreadsafeArray where Element: Equatable {
	public func contains(item: Element) -> Bool {
		self.semaphore.wait()
		defer { semaphore.signal() }
		return self.array.contains(item)
	}

	public mutating func remove(_ item: Element) {
		self.semaphore.wait()
		_ = self.array.remove(item)
		self.semaphore.signal()
	}
	
	public func index(of item: Element) -> Int? {
		self.semaphore.wait()
		defer { semaphore.signal() }
		return self.array.firstIndex(of: item)
	}
}

extension Array {
	init(tsa: ThreadsafeArray<Element>) {
		self.init(tsa.array)
	}
}

public struct ThreadsafeArray<Element> : Sequence, ExpressibleByArrayLiteral {
	public func makeIterator() -> ThreadsafeArrayGenerator<Element> { return ThreadsafeArrayGenerator<Element>(self) }
	
	let semaphore = DispatchSemaphore(value: 1)
	public var array: [Element] = []
	
	public init(_ starter: [Element] = []) {
		array = starter
	}
	
	public init(arrayLiteral: Element...) {
		for element in arrayLiteral {
			self.array.append(element)
		}
	}
	
	public subscript(index: Int) -> Element {
		get {
			self.semaphore.wait()
			let result = self.array[index]
			self.semaphore.signal()
			return result
		}
		set {
			self.semaphore.wait()
			self.array[index] = newValue
			self.semaphore.signal()
		}
	}
	
	public mutating func sort(by comparison: (Element, Element) throws -> Bool) rethrows {
		self.semaphore.wait()
		do {
			let result = try self.array.sorted(by: comparison)
			self.array = result
		} catch {
			self.semaphore.signal()
			throw error
		}
		self.semaphore.signal()
	}
	
	public var count: Int {
		self.semaphore.wait()
		let result = self.array.count
		self.semaphore.signal()
		return result
	}
	
	public mutating func append(_ element: Element) {
		self.semaphore.wait()
		self.array.append(element)
		self.semaphore.signal()
	}
	
	public mutating func remove(at index: Int) {
		self.semaphore.wait()
		self.array.remove(at: index)
		self.semaphore.signal()
	}
	
	public func map<U>(closure: (Element) -> (U)) -> [U] {
		self.semaphore.wait()
		let result = self.array.map(closure)
		self.semaphore.signal()
		return result
	}
	
	public func flatMap<U>(closure: (Element) -> (U)) -> [U] {
		self.semaphore.wait()
		let result = self.array.compactMap(closure)
		self.semaphore.signal()
		return result
	}
	
	public var values: [Element] {
		self.semaphore.wait()
		let result = self.array
		self.semaphore.signal()
		return result
	}
	
	public var first: Element? {
		self.semaphore.wait()
		let result = self.array.first
		self.semaphore.signal()
		return result
	}
	
	public var last: Element? {
		self.semaphore.wait()
		let result = self.array.last
		self.semaphore.signal()
		return result
	}
	
	public mutating func removeAll() {
		self.semaphore.wait()
		self.array.removeAll()
		self.semaphore.signal()
	}
	
	public mutating func append(_ elements: [Element]) {
		self.semaphore.wait()
		self.array += elements
		self.semaphore.signal()
	}
	
	public func index(where check: (Element) -> Bool) -> Int? {
		self.semaphore.wait()
		defer { semaphore.signal() }
		return self.array.firstIndex(where: check)
	}
}

public func +=<Element>(lhs: ThreadsafeArray<Element>, rhs: [Element]) -> ThreadsafeArray<Element> {
	var result = lhs
	result.append(rhs)
	return result
}

public func +<Element>(lhs: ThreadsafeArray<Element>, rhs: ThreadsafeArray<Element>) -> ThreadsafeArray<Element> {
	let a1 = lhs.values
	let a2 = rhs.values
	
	var result = ThreadsafeArray<Element>()
	result.array = a1 + a2
	return result
}

public func +=<Element>( lhs: inout ThreadsafeArray<Element>, rhs: ThreadsafeArray<Element>) {
	lhs = lhs + rhs
}

public func +<Element>(lhs: ThreadsafeArray<Element>, rhs: [Element]) -> ThreadsafeArray<Element> {
	var result = ThreadsafeArray<Element>()
	
	let a1 = lhs.values
	let a2 = rhs
	
	result.array = a1 + a2
	
	return result
}

public func +=<Element>( lhs: inout ThreadsafeArray<Element>, rhs: [Element]) {
	lhs = lhs + rhs
}

public struct ThreadsafeDictionaryGenerator<Key: Hashable, Element>: IteratorProtocol {
	let dict: ThreadsafeDictionary<Key, Element>
	var index = 0
	let keys: [Key]
	
	init(_ d: ThreadsafeDictionary<Key, Element>) {
		dict = d
		index = 0
		keys = Array(d.keys)
	}
	
	public mutating func next() -> (Key, Element?)? {
		if index >= self.keys.count { return nil }
		let key: Key = self.keys[index]
		index += 1
		return (key, self.dict[key])
	}
}



public struct ThreadsafeDictionary<Key: Hashable, Value> : Sequence, ExpressibleByDictionaryLiteral {
	public func makeIterator() -> ThreadsafeDictionaryGenerator<Key, Value> { return ThreadsafeDictionaryGenerator(self) }

	public var dict: [Key: Value] = [:]
	let semaphore = DispatchSemaphore(value: 1)
	
	public init(_ starter: [Key: Value] = [:]) {
		dict = starter
	}
	
	public init(dictionaryLiteral elements: (Key, Value)...) {
		var dict: [Key: Value] = [:]
		
		for (key, value) in elements {
			dict[key] = value
		}
		
		self.dict = dict
	}
	
	public var keys: Dictionary<Key, Value>.Keys {
		self.semaphore.wait()
		let result = self.dict.keys
		self.semaphore.signal()
		return result
	}
	
	public var values: Dictionary<Key, Value>.Values {
		self.semaphore.wait()
		let result = self.dict.values
		self.semaphore.signal()
		return result
	}
	
	public subscript(key: Key) -> Value? {
		get {
			self.semaphore.wait()
			let result = self.dict[key]
			self.semaphore.signal()
			return result
		}
		set {
			self.semaphore.wait()
			if newValue == nil {
				self.dict.removeValue(forKey: key)
			} else {
				self.dict[key] = newValue
			}
			self.semaphore.signal()
		}
	}
	public var count: Int {
		self.semaphore.wait()
		let count = self.dict.count
		self.semaphore.signal()
		return count
	}

}

