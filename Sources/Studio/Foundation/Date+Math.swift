//
//  Date+Math.swift
//  
//
//  Created by Ben Gottlieb on 6/13/21.
//

import Foundation

@available(iOS 10.0, watchOS 5.0, *)
public extension Array where Element == DateInterval {
	mutating func add(_ new: DateInterval) {
		for interval in self {
			if interval.contains(new) { return }			// already contained within
		}

		for index in self.indices.reversed() {
			if new.contains(self[index]) { self.remove(at: index) }
		}

		let startIndex = firstIndex { $0.contains(new.start) }
		let endIndex = firstIndex { $0.contains(new.end) }
		
		if let firstIndex = startIndex, let lastIndex = endIndex {
			let first = self[firstIndex]
			let last = self[lastIndex]
			
			self.removeSubrange(firstIndex..<lastIndex)
			self.insert(DateInterval(start: first.start, end: last.end), at: firstIndex)
			return
		}
		
		if let firstIndex = startIndex {
			self[firstIndex].end = new.end
			
			return
		}

		if let lastIndex = endIndex {
			self[lastIndex].start = new.start
			return
		}
		
		self.append(new)
		self.sort() { $0.start < $1.start }
	}
}

@available(iOS 10.0, watchOS 5.0, *)
public extension DateInterval {
	func contains(_ interval: DateInterval) -> Bool {
		start <= interval.start && end >= interval.end
	}
}
