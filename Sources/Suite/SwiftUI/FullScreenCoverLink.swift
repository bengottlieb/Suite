//
//  FullScreenCover.swift
//  
//
//  Created by Ben Gottlieb on 3/6/23.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 12.0, iOS 14.0, watchOS 8.0, *)
public struct FullScreenCoverLink<Label: View, Content: View>: View {
	let label: () -> Label
	let content: () -> Content
	
	@State private var isPresented = false
	
	public init(label: @escaping () -> Label, content: @escaping () -> Content) {
		self.label = label
		self.content = content
	}
	
	public var body: some View {
		Button(action: { isPresented.toggle() }) {
			label()
		}
		.fullScreenCover(isPresented: $isPresented, content: content)
	}
}

@available(OSX 12.0, iOS 14.0, watchOS 8.0, *)
extension FullScreenCoverLink where Label == Text {
	public init(_ title: String, content: @escaping () -> Content) {
		self.label = { Text(title) }
		self.content = content
	}
}

#endif
