//
//  AcceptsFirstMouse.swift
//
//
//  Created by Ben Gottlieb on 8/18/23.
//

import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension View {
	func acceptsFirstMouse() -> some View {
		#if os(macOS)
			self
				.overlay(AcceptingFirstMouse())
		#else
			self
		#endif
	}
}

#if os(macOS)
@available(OSX 10.15, *)
struct AcceptingFirstMouse : NSViewRepresentable {
	func makeNSView(context: NSViewRepresentableContext<AcceptingFirstMouse>) -> FirstClickableView {
		return FirstClickableView()
	}
	
	func updateNSView(_ nsView: FirstClickableView, context: NSViewRepresentableContext<AcceptingFirstMouse>) {
		nsView.setNeedsDisplay(nsView.bounds)
	}
	
	class FirstClickableView : NSView {
		 override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
			  return true
		 }
	}
}
#endif
