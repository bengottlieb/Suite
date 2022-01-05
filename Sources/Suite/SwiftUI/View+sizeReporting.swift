//
//  View+SizeReporting.swift
//  
//
//  Created by ben on 4/5/20.
//

#if canImport(SwiftUI)
#if canImport(Combine)

import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct SizeViewModifier: ViewModifier {
    @Binding var size: CGSize
    
    public func body(content: Content) -> some View {
		content.background(
			GeometryReader() { geo -> Color in
				DispatchQueue.main.async { size = geo.size }
				return Color.clear
			}
		)
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
fileprivate struct SizePreferenceKey: PreferenceKey {
	static var defaultValue: CGSize = .zero
	static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
struct SizeReporter<Content: View>: View {
	@Binding var size: CGSize
	let content: Content
	
	var body: some View {
		content
			.background(
				GeometryReader() { geo in
					Color.clear
						.preference(key: SizePreferenceKey.self, value: geo.size)
				}
			)
			.onPreferenceChange(SizePreferenceKey.self) { newSize in
				size = newSize
			}
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension View {		// Tracks the size available for the view
	func sizeReporting(_ size: Binding<CGSize>) -> some View {
		SizeReporter(size: size, content: self)
	}

	func frameReporting(_ frame: Binding<CGRect>, in space: CoordinateSpace = .global, firstTimeOnly: Bool = false) -> some View {
			self
					.background(GeometryReader() { geo -> Color in
						let rect = geo.frame(in: space)
						DispatchQueue.main.async {
							if (!firstTimeOnly || frame.wrappedValue == .zero) && frame.wrappedValue != rect  { frame.wrappedValue = rect }
						}
						return Color.clear
					})
	}

	func sizeReporting(_ callback: @escaping (CGSize) -> Void) -> some View {
		self.background(
			GeometryReader() { geo -> Color in
				DispatchQueue.main.async { callback(geo.size) }
				return Color.clear
			}
		)
	}
}

#endif
#endif
