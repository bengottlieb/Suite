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

private let formatter: NumberFormatter = {
	let formatter = NumberFormatter()
	formatter.numberStyle = .decimal
	formatter.maximumFractionDigits = 2
	formatter.minimumFractionDigits = 2
	return formatter
}()

public extension DecimalFormattable {
	func string(decimalPlaces: Int = 2, padded: Bool = false) -> String {
		var result: String!
			
		if decimalPlaces <= 2 {
			result = formatter.string(from: NSNumber(value: doubleValue))
		}
		if result == nil { result = String(format: "%.\(decimalPlaces)f", doubleValue) }
		
		while result.hasSuffix("0") || result.decimalPlaces > decimalPlaces {
			result = String(result.dropLast())
		}
		
		if padded {
			while result.decimalPlaces < decimalPlaces, result.count < 500 {
				result += "0"
			}
		} else {
			if result.hasSuffix(".") { result = String(result.dropLast()) }
		}
		
		return result
	}
}

public extension String {
	var decimalPlaces: Int {
        var radix = NumberFormatter.radix
		if !contains(radix) { radix = "," }
		if !contains(radix) { return 0 }
		let components = self.components(separatedBy: radix)
		return components.last?.count ?? 0
	}
}

extension NumberFormatter {
    static var radix: String = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        guard let result = formatter.string(from: NSNumber(1.1)) else { return "." }
        if result.contains(".") { return "." }
        if result.contains(",") { return "," }
        if let last = result.trimmingCharacters(in: .alphanumerics).first {
            return String(last)
        }
        return "."
    }()
}
