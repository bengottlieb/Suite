//
//  OptionSet.swift
//  
//
//  Created by Ben Gottlieb on 11/30/20.
//

import Foundation

public extension OptionSet {
	mutating func toggle(_ value: Self.Element) {
		if self.contains(value) {
			self.remove(value)
		} else {
			self.insert(value)
		}
	}
}
