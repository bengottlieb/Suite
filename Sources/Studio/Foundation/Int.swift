//
//  Int.swift
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

public extension FixedWidthInteger {
	var characterCode: String {
		let bytes = self.bytes
		
		return bytes.reduce("") { $1 == 0 ? $0 : $0 + String(UnicodeScalar($1)) }
	}

	var bytes: [UInt8] {
		Array(0..<byteWidth).map { byte($0) }
	}
	
	var byteWidth: Int { bitWidth / 8 }
 
	func byte(_ index: Int) -> UInt8 {
		
		if index >= byteWidth { return 0 }
		return UInt8((self >> (bitWidth - (index + 1) * 8)) & 0x000000FF)
	}
	
	var b1: UInt8 { byte(0) }
	var b2: UInt8 { byte(1) }
	var b3: UInt8 { byte(2) }
	var b4: UInt8 { byte(3) }

	static func random(to max: UInt32) -> UInt32 {
		let rnd = arc4random_uniform(max)
		return rnd
	}
}

public extension UInt32 {
	var fourCharacterCode: String {
		let utf16 = [
			UInt16((self & 0xFF)),
			UInt16((self >> 8) & 0xFF),
			UInt16((self >> 16) & 0xFF),
			UInt16((self >> 24) & 0xFF),
		]
		return String(utf16CodeUnits: utf16, count: 4)
	}
}
