//
//  File.swift
//  
//
//  Created by ben on 3/6/20.
//

import Foundation

public extension Numeric where Self: Comparable {
	func capped(_ range: ClosedRange<Self>) -> Self {
		if self < range.lowerBound { return range.lowerBound }
		if self > range.upperBound { return range.upperBound }
		return self
	}
}
