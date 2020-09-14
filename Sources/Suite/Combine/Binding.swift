//
//  Binding.swift
//  InternalUI
//
//  Created by Ben Gottlieb on 2/19/20.
//  Copyright © 2020 DataBright. All rights reserved.
//

#if canImport(SwiftUI)
#if canImport(Combine)
import SwiftUI
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension Binding {
	static func mock<Value>(value: Value) -> Binding<Value> {
		var value = value
		return Binding<Value>(get: { return value }) { value = $0 }
	}

	static func mock<Value>(value: Value?) -> Binding<Value?> {
		var value = value
		return Binding<Value?>(get: { return value }) { value = $0 }
	}
	
	func onChange(_ completion: @escaping (Value) -> Void) -> Binding<Value> {
		Binding<Value>(get: { self.wrappedValue }, set: { newValue in
			self.wrappedValue = newValue
			completion(newValue)
		})
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension Binding where Value: Equatable {
	init(_ source: Binding<Value?>, nilValue: Value) {
		self.init(
			get: { source.wrappedValue ?? nilValue },
			set: { newValue in
				if newValue == nilValue {
					source.wrappedValue = nil
				} else {
					source.wrappedValue = newValue
				}
			})
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension Binding {
	var optional: Binding<Value?> {
		Binding<Value?>(get: { self.wrappedValue }, set: { opt in
			if let val = opt { self.wrappedValue = val }
		})
	}
	
	init(readonly: Value) {
		self.init(get: { return readonly }, set: { _ in })
	}
	
	init<T>(isNotNil source: Binding<T?>, defaultValue: T) where Value == Bool {
		self.init(get: { source.wrappedValue != nil }, set: { source.wrappedValue = $0 ? defaultValue : nil })
	}
}

#endif
#endif
