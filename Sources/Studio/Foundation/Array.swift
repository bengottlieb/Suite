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

public extension Array {
	subscript(index index: Int?) -> Element? {
		guard let idx = index, idx < self.count else { return nil }
		return self[idx]
	}
	
	func breakIntoChunks(ofSize size: Int) -> [[Element]] {
		if self.count <= size { return [self] }

		let count = self.count
		var start = size
		var results: [[Element]] = [Array(self[0..<size])]
		
		while (count - start) >= size {
			results.append(Array(self[start..<(start + size)]))
			start += size
		}
		
		
		if start < count {
			results.append(Array(self[start..<count]))
		}
		
		return results
	}
}
