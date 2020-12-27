//
//  View+Debug.swift
//  
//
//  Created by Ben Gottlieb on 9/5/20.
//

#if canImport(SwiftUI)
#if canImport(Combine)

import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension View {
	func logg(_ text: String?) -> some View {
		Studio.logg(text ?? "")
		return self
	}
	
	func debug(_ action: () -> Void) -> some View {
		#if DEBUG
		action()
		#endif
		return self
	}
	
	func debugModifier<T: View>(_ modifier: (Self) -> T) -> some View {
		#if DEBUG
		return modifier(self)
		#else
		return self
		#endif
	}
	
	func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
		debugModifier {
			$0.border(color, width: width)
		}
	}
	
	func debugBackground(_ color: Color = .red) -> some View {
		debugModifier {
			$0.background(color)
		}
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct Log: View {
	public init(_ text: String?) {
		Studio.logg(text ?? "")
	}
	
	public var body: some View { EmptyView() }
}


@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct StatefulPreview<Value, Content: View>: View {
	@State var value: Value
	var content: (Binding<Value>) -> Content
	
	public var body: some View {
		content($value)
	}
	
	public init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
		self._value = State(wrappedValue: value)
		self.content = content
	}
}

#endif
#endif
