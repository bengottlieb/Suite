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
}
