//
//  NumericField.swift
//  
//
//  Created by Ben Gottlieb on 6/6/20.
//

#if canImport(SwiftUI)
#if canImport(Combine)

import SwiftUI
import UIKit

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
	public var title: String
	@Binding public var number: Number
	public var formatter: NumberFormatter
	public init(_ title: String, number: Binding<Number>, formatter: NumberFormatter = NumberFormatter()) {
		self.title = title
		self._number = number
		self.formatter = formatter
	}
	
	var textBinding: Binding<String> {
		Binding<String>(get: {
			self.formatter.string(from: NSNumber(value: self.number)) ?? ""
		}, set: { new in
			if let newNumber = self.formatter.number(from: new)?.convert(to: Number.self) {
				self.number = newNumber
			}
		})
	}
	
	public var body: some View {
		TextField(title, text: textBinding)
			
	}
}

#endif
#endif
