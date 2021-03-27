//
//  NumberFormatting.swift
//  
//
//  Created by Ben Gottlieb on 3/26/21.
//

import Foundation

#if canImport(UIKit)
	import UIKit
#elseif canImport(Cocoa)
	import Cocoa
#endif

public protocol DecimalFormattable {
	var doubleValue: Double { get }
}

extension CGFloat: DecimalFormattable {
	public var doubleValue: Double { Double(self) }
}

extension Double: DecimalFormattable {
	public var doubleValue: Double { self }
}

extension Float: DecimalFormattable {
	public var doubleValue: Double { Double(self) }
}

public extension DecimalFormattable {
	func string(decimalPlaces: Int = 2) -> String {
		var result = String(format: "%.\(decimalPlaces)f", doubleValue)
		
		while result.hasSuffix(".") || result.hasSuffix("0") {
			result = String(result.dropLast())
		}
		
		return result
	}
}
