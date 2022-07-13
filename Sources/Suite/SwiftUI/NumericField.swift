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
    var positive: NumericFieldNumber { get }
    var negative: NumericFieldNumber { get }
}

extension Double: NumericFieldNumber {
	public func isLessThan(numericFieldNumber number: NumericFieldNumber) -> Bool { self < (number as? Double ?? 0) }
	public func isEqualTo(numericFieldNumber number: NumericFieldNumber?) -> Bool { self == (number as? Double ?? 0) }
	mutating public func zeroOut() { self = 0 }
    public var positive: NumericFieldNumber { abs(self) }
    public var negative: NumericFieldNumber { -1 * abs(self) }
}
extension Int: NumericFieldNumber {
	public func isLessThan(numericFieldNumber number: NumericFieldNumber) -> Bool { self < (number as? Int ?? 0) }
	public func isEqualTo(numericFieldNumber number: NumericFieldNumber?) -> Bool { self == (number as? Int ?? 0) }
	mutating public func zeroOut() { self = 0 }
    public var positive: NumericFieldNumber { abs(self) }
    public var negative: NumericFieldNumber { -1 * abs(self) }
}

extension Float: NumericFieldNumber {
	public func isLessThan(numericFieldNumber number: NumericFieldNumber) -> Bool { self < (number as? Float ?? 0) }
	public func isEqualTo(numericFieldNumber number: NumericFieldNumber?) -> Bool { self == (number as? Float ?? 0) }
	mutating public func zeroOut() { self = 0 }
    public var positive: NumericFieldNumber { abs(self) }
    public var negative: NumericFieldNumber { -1 * abs(self) }
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
    public enum AllowedSigns { case negative, positive, both }
	public var placeholder: String
	@Binding public var number: Number
	public var formatter: NumberFormatter
	public var useKeypad = true
	public var showInitialZeroAsEmptyString = true
	public var onChange: (Bool) -> Void
	public var onCommit: () -> Void
	let minimum: Number?
	let maximum: Number?
	let maxNumberOfCharacters: Int?
	let allowedSigns: AllowedSigns
	let maximumFractionDigits: Int?
	@State var hasModified = false
	@State var text = ""
	@State var oldText = ""
	
	let radix = Locale.current.decimalSeparator?.first ?? "."
	let groupSeparator = Locale.current.groupingSeparator?.first ?? ","

	public init(_ placeholder: String, number: Binding<Number>, formatter: NumberFormatter? = nil, useKeypad: Bool = true, minimum: Number? = nil, showInitialZeroAsEmptyString: Bool = true, maximum: Number? = nil, allowedSigns: AllowedSigns = .both, maxNumberOfCharacters: Int? = nil, maximumFractionDigits: Int = 12, onChange: @escaping (Bool) -> Void = { _ in }, onCommit: @escaping () -> Void = { }) {
		self.placeholder = placeholder
		self._number = number
		self.onCommit = onCommit
		self.onChange = onChange
		self.useKeypad = useKeypad
		self.minimum = minimum
		self.maximum = maximum
		self.allowedSigns = allowedSigns
		self.showInitialZeroAsEmptyString = showInitialZeroAsEmptyString
		self.maxNumberOfCharacters = maxNumberOfCharacters
		self.maximumFractionDigits = maximumFractionDigits
		
		self.formatter = formatter ?? NumberFormatter.formatter(for: number.wrappedValue, maximumFractionDigits: maximumFractionDigits)
		var newText = self.formatter.string(from: NSNumber(value: number.wrappedValue)) ?? ""
		if showInitialZeroAsEmptyString, newText == "0" { newText = "" }
		_text = State(initialValue: newText)
	}
	
	public var body: some View {
		#if os(iOS)
		rawField
			.keyboardType(useKeypad ? .decimalPad : .asciiCapable)
		#else
		rawField
		#endif
	}
	
	func numberStringsAreEqual(oldText: String, newText: String) -> Bool {
		if oldText == newText { return true }
		
		var filtered = oldText.contains(".") ? oldText.trimmingCharacters(in: CharacterSet(charactersIn: "0")) : oldText
		if filtered == "." { filtered = "0." }
		if Double(filtered) == Double(newText), filtered.hasSuffix(".") { return true }
		
		return false
	}

	var textBinding: Binding<String> {
		Binding<String>(get: {
			if NSNumber(value: number) == NSNumber(value: 0), !hasModified { return "" }
			let newText = self.formatter.string(from: NSNumber(value: number)) ?? ""
			//if !number.isEqualTo(numericFieldNumber: parsedNumber(from: text)) {
			if !numberStringsAreEqual(oldText: oldText, newText: newText) {
				DispatchQueue.main.async {
					self.text = newText
					self.oldText = newText
				}
			}
			return self.text
		}) { newText in
			if let max = maxNumberOfCharacters, newText.count > max {
				self.text = oldText
			} else {
				self.text = newText
				self.oldText = newText
				self.hasModified = true
			}
		}
	}
	
	func parsedNumber(from newText: String) -> Number? {
		let numbersOnly = newText.filter {
            if $0.isNumber { return true }
            if $0 == radix { return true }
            if (allowedSigns == .negative || allowedSigns == .both), $0 == "-" { return true }
            return false
        }
		if let newNumber = formatter.number(from: String(numbersOnly)) as? Number {
            if allowedSigns == .positive { return newNumber.positive as? Number }
            if allowedSigns == .negative { return newNumber.negative as? Number }
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
	static func formatter(for number: NumericFieldNumber, maximumFractionDigits: Int = 12) -> NumberFormatter {
		let formatter = NumberFormatter()
		
		if number is Double || number is Float {
			formatter.numberStyle = .decimal
			formatter.maximumFractionDigits = maximumFractionDigits
		} else {
			formatter.numberStyle = .none
		}
		return formatter
	}
}

#endif
#endif
