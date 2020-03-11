//
//  Binding.swift
//  
//
//  Created by Ben Gottlieb on 3/11/20.
//

#if canImport(SwiftUI)
import SwiftUI

@available(OSX 10.15, iOS 13.0, *)
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

#endif
