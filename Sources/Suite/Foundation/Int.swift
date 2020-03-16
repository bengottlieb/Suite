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

public extension UInt32 {
	var bytes: [UInt8] {
		return [self.b1, self.b2, self.b3, self.b4]
	}
	
	var b1: UInt8 { return UInt8((self >> 24) & 0x000000FF) }
	var b2: UInt8 { return UInt8((self >> 16) & 0x000000FF) }
	var b3: UInt8 { return UInt8((self >> 8) & 0x000000FF) }
	var b4: UInt8 { return UInt8((self >> 0) & 0x000000FF) }

	static func random(to max: UInt32) -> UInt32 {
		let rnd = arc4random_uniform(max)
		return rnd
	}

}

