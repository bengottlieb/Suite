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
fileprivate struct FramePreferenceKey: PreferenceKey {
	static var defaultValue: CGRect = .zero
	static func reduce(value: inout CGRect, nextValue: () -> CGRect) { }
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

	func sizeLogging(_ logString: String) -> some View {
		self.background(
			GeometryReader() { geo -> Color in
				print("\(logString): \(geo.size)")
				return Color.clear
			}
		)
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension View {
	func sizeDisplaying() -> some View {
		self
			.overlay(SizeOverlay())
	}

	func positionDisplaying() -> some View {
		self
			.overlay(PositionOverlay())
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
struct SizeOverlay: View {
	@State var size: CGSize?
	
	let dimensionsTextColor = Color.white
	let dimensionsColor = Color.red
	let dimensionThickness = 1.0
	
	var aspectRatioString: String {
		if let size = size {
			return String(format: "%.2f", size.width / size.height)
		} else {
			return ""
		}
	}
	
	var body: some View {
		ZStack() {
			GeometryReader { geo in
				Color.clear
					.preference(key: SizePreferenceKey.self, value: geo.size)
			}
			.onPreferenceChange(SizePreferenceKey.self) { newSize in
				size = newSize
			}
			
			if let size = size {
				HStack(spacing: 0) {
					ZStack() {
						Text("\(Int(size.height))")
							.foregroundColor(dimensionsTextColor)
							.padding(.horizontal, 6)
							.padding(.vertical, 3)
							.background(Capsule().fill(dimensionsColor))
							.rotationEffect(.degrees(270))
							.padding(.leading, -5)
					}
					Color.clear
				}

				VStack(spacing: 0) {
					ZStack() {
						Text("\(Int(size.width)), \(aspectRatioString)")
							.foregroundColor(dimensionsTextColor)
							.padding(.horizontal, 6)
							.padding(.vertical, 3)
							.background(Capsule().fill(dimensionsColor))
							.padding(1)
					}
					Color.clear
				}
			}
		}
		.overlay(dimension.padding(-dimensionThickness / 2))
		.font(.system(size: 10, weight: .semibold))
	}
	
	var dimension: some View {
		Rectangle()
			.strokeBorder(dimensionsColor, style: StrokeStyle(lineWidth: dimensionThickness, dash: [dimensionThickness]))
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
struct PositionOverlay: View {
	@State var viewFrame: CGRect?
	var coordinateSpace = CoordinateSpace.global
	
	let dimensionsTextColor = Color.white
	let dimensionsColor = Color.red
	
	var body: some View {
		ZStack() {
			GeometryReader { geo in
				Color.clear
					.preference(key: FramePreferenceKey.self, value: geo.frame(in: coordinateSpace))
			}
			.onPreferenceChange(FramePreferenceKey.self) { newFrame in
				viewFrame = newFrame
			}
			
			if let frame = viewFrame {
					Text("(\(Int(frame.minX)), \(Int(frame.minY)))")
						.foregroundColor(dimensionsTextColor)
						.padding(.horizontal, 6)
						.padding(.vertical, 3)
						.background(Capsule().fill(dimensionsColor))
						.padding(1)
			}
		}
		.font(.system(size: 10, weight: .semibold))
	}
}
#endif
#endif
