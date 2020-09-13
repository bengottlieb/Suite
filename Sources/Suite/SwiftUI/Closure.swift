//
//  Closure.swift
//  
//
//  Created by Ben Gottlieb on 9/12/20.
//

#if canImport(SwiftUI)
#if canImport(Combine)
import SwiftUI
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct Closure: View {
	let closure: () -> Void
	
	public init(_ closure: @escaping () -> Void) {
		self.closure = closure
	}
	
	public init(_ closure: @escaping @autoclosure () -> Void) {
		self.closure = closure
	}
	
	public var body: some View {
		closure()
		return EmptyView()
	}
}
#endif
#endif
