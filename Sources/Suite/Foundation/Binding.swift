//
//  Binding.swift
//  
//
//  Created by Ben Gottlieb on 3/11/20.
//

#if canImport(SwiftUI)
#if canImport(Combine)
import SwiftUI
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct Binder<Object, Output> {
	public init(_ output: Output.Type) { }
	public init() { }

	public func bind(_ object: Object, path: ReferenceWritableKeyPath<Object, Output>, didSet: ((Output) -> Void)? = nil) -> Binding<Output> {
		Binding<Output>(
			get: { return object[keyPath: path] },
			set: { newValue in object[keyPath: path] = newValue; didSet?(newValue) }
		)
	}

	public func bind(_ object: Object, path: KeyPath<Object, Output>, didSet: ((Output) -> Void)? = nil) -> Binding<Output> {
		Binding<Output>(
			get: { return object[keyPath: path] },
			set: { newValue in didSet?(newValue) }
		)
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
	init<T>(isNotNil source: Binding<T?>, defaultValue: T) where Value == Bool {
		self.init(get: { source.wrappedValue != nil }, set: { source.wrappedValue = $0 ? defaultValue : nil })
	}
}

#endif
#endif
