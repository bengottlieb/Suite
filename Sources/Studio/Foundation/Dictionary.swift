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
