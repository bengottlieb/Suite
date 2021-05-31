//
//  NumericField.swift
//  
//
//  Created by Ben Gottlieb on 6/6/20.
//

#if canImport(SwiftUI)
#if canImport(Combine)

import SwiftUI
import CoreGraphics

public protocol NumericFieldNumber { }

extension Double: NumericFieldNumber {}
extension Int: NumericFieldNumber {}
extension Float: NumericFieldNumber {}

extension NSNumber {
	convenience init(value: NumericFieldNumber) {
		if let number = value as? Double {
			self.init(value: number)
		} else if let number = value as? Int {
			self.init(value: number)
		} else if let number = value as? Float {
			self.init(value: number)
		} else {
			fatalError("Invalid numeric type")
		}
	}
	
	func convert<Number: NumericFieldNumber>(to numberType: Number.Type) -> Number? {
		if numberType.self == Int.self {
			return self.intValue as? Number
		} else if numberType.self == Double.self {
			return self.doubleValue as? Number
		} else if numberType.self == Float.self {
			return self.floatValue as? Number
		} else {
			fatalError("Invalid numeric type")
		}
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct NumericField<Number: NumericFieldNumber>: View {
	public var placeholder: String
	@Binding public var number: Number
	@State var text: String
	public var formatter: NumberFormatter
	public init(_ placeholder: String, number: Binding<Number>, formatter: NumberFormatter? = nil) {
		self.placeholder = placeholder
		self._number = number
		
		let actualFormatter = formatter ?? NumberFormatter.formatter(for: number.wrappedValue)
		self.formatter = actualFormatter
		_text = State(initialValue: actualFormatter.string(from: NSNumber(value: number.wrappedValue)) ?? "")
	}

	public var body: some View {
		#if os(iOS)
			rawField
				.keyboardType(.decimalPad)
		#else
			rawField
		#endif
	}
	
	var rawField: some View {
		TextField(placeholder, text: $text.onChange { newText in
			if let newNumber = formatter.number(from: newText) as? Number {
				number = newNumber
			}
		})
	}
}

extension NumberFormatter {
	static func formatter(for number: NumericFieldNumber) -> NumberFormatter {
		let formatter = NumberFormatter()
		
		if number is Double || number is Float {
			formatter.numberStyle = .decimal
		} else {
			formatter.numberStyle = .none
		}
		return formatter
	}
}

#endif
#endif
