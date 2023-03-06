//
//  FullWidthButtonStyle.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/4/23.
//

import SwiftUI

public struct FullWidthButtonStyle: ButtonStyle {
	var foregroundColor: Color?
	var backgroundColor: Color?
	
	@Environment(\.isEnabled) private var isEnabled: Bool
	
	
	public init(foreground: Color? = nil, background: Color? = nil) {
		foregroundColor = foreground
		backgroundColor = background
	}

	public func makeBody(configuration: FullWidthButtonStyle.Configuration) -> some View {
		configuration.label
			.padding()
			.frame(maxWidth: .infinity)
			.background(backgroundColor ?? Color.accentColor)
			.foregroundColor(foregroundColor ?? Color.systemBackground)
			.opacity(isEnabled ? 1 : 0.4)
			.frame(maxWidth: .infinity)
			.frame(height: 50)
			.cornerRadius(8)
			.scaleEffect(configuration.isPressed ? 0.98 : 1)
			.animation(.linear(duration: 0.1), value: configuration.isPressed)
	}
}
 

