//
//  FullWidthButtonStyle.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public struct FullWidthButtonStyle: ButtonStyle {
	var foregroundColor: Color?
	var backgroundColor: Color?
	let borderOnly: Bool
	let borderWidth: Double
	let cornerRadius = 8.0
	@Environment(\.isEnabled) private var isEnabled: Bool
	
	
	public init(foreground: Color? = nil, background: Color? = nil, borderOnly: Bool = false, borderWidth: Double = 0.0) {
		foregroundColor = foreground
		backgroundColor = background
		self.borderOnly = borderOnly
		self.borderWidth = borderWidth
	}

	var resolvedForeground: Color {
		#if os(iOS) || os(macOS)
			if !borderOnly { return foregroundColor ?? Color.systemBackground }
		#else
			if !borderOnly { return foregroundColor ?? .black }
		#endif
		return foregroundColor ?? Color.accentColor
	}
	
	var resolvedBackground: Color {
		#if os(iOS) || os(macOS)
			if !borderOnly { return backgroundColor ?? Color.accentColor }
			return backgroundColor ?? Color.systemBackground
		#else
			if !borderOnly { return foregroundColor ?? .white }
			return backgroundColor ?? Color.black
		#endif
	}
	
	public func makeBody(configuration: FullWidthButtonStyle.Configuration) -> some View {
		configuration.label
			.padding()
			.frame(maxWidth: .infinity)
			.background (
				ZStack {
					if !borderOnly {
						RoundedRectangle(cornerRadius: cornerRadius)
							.fill(resolvedBackground)
					}
					if borderWidth > 0 {
						RoundedRectangle(cornerRadius: cornerRadius)
							.stroke(resolvedForeground)
					}
				}
			)
			.foregroundColor(resolvedForeground)
			.opacity(isEnabled ? 1 : 0.4)
			.frame(maxWidth: .infinity)
			.frame(height: 50)
			.scaleEffect(configuration.isPressed ? 0.98 : 1)
			.animation(.linear(duration: 0.1), value: configuration.isPressed)
	}
}
 

#endif
