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
	public var formatter: NumberFormatter
    public var useKeypad = true
	public var onChange: (Bool) -> Void
	public var onCommit: () -> Void
	
    public init(_ placeholder: String, number: Binding<Number>, formatter: NumberFormatter? = nil, useKeypad: Bool = true, onChange: @escaping (Bool) -> Void = { _ in }, onCommit: @escaping () -> Void = { }) {
		self.placeholder = placeholder
		self._number = number
		self.onCommit = onCommit
		self.onChange = onChange
        self.useKeypad = useKeypad
		
		self.formatter = formatter ?? NumberFormatter.formatter(for: number.wrappedValue)
	}

	public var body: some View {
		#if os(iOS)
			rawField
                .keyboardType(useKeypad ? .decimalPad : .asciiCapable)
		#else
			rawField
		#endif
	}
	
	var textBinding: Binding<String> {
		Binding<String>(get: {
			formatter.string(from: NSNumber(value: number)) ?? ""
		}) { newText in
			if let newNumber = formatter.number(from: newText) as? Number {
				number = newNumber
			}
		}
	}
	
	var rawField: some View {
		TextField(placeholder, text: textBinding, onEditingChanged: onChange, onCommit: onCommit)
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
