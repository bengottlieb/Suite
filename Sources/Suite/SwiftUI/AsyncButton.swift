//
//  AsyncButton.swift
//  
//
//  Created by Ben Gottlieb on 1/5/22.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct AsyncButton<Label: View>: View {
	var action: () async -> Void
	@ViewBuilder var label: () -> Label
	
	@State private var isPressed = false
	
	public init(action: @escaping () async -> Void, @ViewBuilder label: @escaping () -> Label) {
		self.action = action
		self.label = label
	}
	
	public var body: some View {
		Button(action: {
				Task {
					isPressed = true
					await action()
					isPressed = false
				}
			}) {
				ZStack {
					if isPressed {
						label().opacity(0)
						if #available(OSX 11, iOS 14.0, watchOS 7, *) {
							ProgressView()
						} else {
							label().opacity(0.2)
						}
					} else {
						label()
					}
				}
			}
		
		.disabled(isPressed)
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension AsyncButton where Label == Text {
	public init(_ title: String, action: @escaping () async -> Void) {
		self.action = action
		self.label = { Text(title) }
	}
}
#endif
