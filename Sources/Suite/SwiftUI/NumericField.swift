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

public protocol NumericFieldNumber {
	func isLessThan(numericFieldNumber number: NumericFieldNumber) -> Bool
	func isEqualTo(numericFieldNumber number: NumericFieldNumber?) -> Bool
	mutating func zeroOut()
}

extension Double: NumericFieldNumber {
	public func isLessThan(numericFieldNumber number: NumericFieldNumber) -> Bool { self < (number as? Double ?? 0) }
	public func isEqualTo(numericFieldNumber number: NumericFieldNumber?) -> Bool { self == (number as? Double ?? 0) }
	mutating public func zeroOut() { self = 0 }
}
extension Int: NumericFieldNumber {
	public func isLessThan(numericFieldNumber number: NumericFieldNumber) -> Bool { self < (number as? Int ?? 0) }
	public func isEqualTo(numericFieldNumber number: NumericFieldNumber?) -> Bool { self == (number as? Int ?? 0) }
	mutating public func zeroOut() { self = 0 }
}
extension Float: NumericFieldNumber {
	public func isLessThan(numericFieldNumber number: NumericFieldNumber) -> Bool { self < (number as? Float ?? 0) }
	public func isEqualTo(numericFieldNumber number: NumericFieldNumber?) -> Bool { self == (number as? Float ?? 0) }
	mutating public func zeroOut() { self = 0 }
}

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
	let minimum: Number?
	let maximum: Number?
	@State var text = ""
	
	let radix = Locale.current.decimalSeparator?.first ?? "."
	let groupSeparator = Locale.current.groupingSeparator?.first ?? ","

	public init(_ placeholder: String, number: Binding<Number>, formatter: NumberFormatter? = nil, useKeypad: Bool = true, minimum: Number? = nil, maximum: Number? = nil, onChange: @escaping (Bool) -> Void = { _ in }, onCommit: @escaping () -> Void = { }) {
		self.placeholder = placeholder
		self._number = number
		self.onCommit = onCommit
		self.onChange = onChange
		self.useKeypad = useKeypad
		self.minimum = minimum
		self.maximum = maximum
		
		self.formatter = formatter ?? NumberFormatter.formatter(for: number.wrappedValue)
		_text = State(initialValue: self.formatter.string(from: NSNumber(value: number.wrappedValue)) ?? "")
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
			if !number.isEqualTo(numericFieldNumber: parsedNumber(from: text)) {
				DispatchQueue.main.async {
					self.text = self.formatter.string(from: NSNumber(value: number)) ?? ""
				}
			}
			return self.text
		}) { newText in
			self.text = newText
		}
	}
	
	func parsedNumber(from newText: String) -> Number? {
		let numbersOnly = newText.filter { $0.isNumber || $0 == radix }
		if let newNumber = formatter.number(from: String(numbersOnly)) as? Number {
			return newNumber
		}
		return nil
	}
	
	var rawField: some View {
		TextField(placeholder, text: textBinding.willChange { newText in
			if newText.isEmpty {
				number.zeroOut()
				return
			}
			let oldText = text
			let noLetters = newText.filter { $0.isNumber || $0 == radix || $0 == groupSeparator }
			if noLetters != newText {
				DispatchQueue.main.async { text = oldText }
				return
			}
			if let newNumber = parsedNumber(from: newText) {
				if let min = minimum, newNumber.isLessThan(numericFieldNumber: min) {
					DispatchQueue.main.async { text = oldText }
					return
				}

				if let max = maximum, max.isLessThan(numericFieldNumber: newNumber) {
					DispatchQueue.main.async { text = oldText }
					return
				}

				number = newNumber
			}
		}, onEditingChanged: onChange, onCommit: onCommit)
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
