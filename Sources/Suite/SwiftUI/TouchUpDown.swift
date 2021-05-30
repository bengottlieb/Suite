//
//  TouchUpDownActions.swift
//  
//
//  Created by Ben Gottlieb on 5/29/21.
//

#if canImport(Combine)
import SwiftUI

@available(macOS 10.15, iOS 13.0, watchOS 7.0, *)
struct TouchUpDownActions: ViewModifier {
	var touchDown: (() -> Void)?
	var touchUp: (() -> Void)?
	
	func body(content: Content) -> some View {
		content
			.simultaneousGesture(
				DragGesture(minimumDistance: 0)
					.onChanged { _ in touchDown?() }
					.onEnded { _ in touchUp?() }
			)
	}
}

@available(macOS 10.15, iOS 13.0, watchOS 7.0, *)
struct TouchRepeatingView<Content: View>: View {
	let content: Content
	let interval: TimeInterval
	let action: () -> Void
	@State private var timer: Timer?
	
	var body: some View {
		content
			.touchActions(touchDown: touchDown, touchUp: touchUp)
			.onDisappear() {
				timer?.invalidate()
				timer = nil
			}
	}
	
	func touchDown() {
		if timer != nil { return }
		action()
		timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { _ in action() })
	}
	
	func touchUp() {
		timer?.invalidate()
		timer = nil
	}

}

@available(macOS 10.15, iOS 13.0, watchOS 7.0, *)
public extension View {
	func touchActions(touchDown: (() -> Void)? = nil, touchUp: (() -> Void)? = nil) -> some View {
		modifier(TouchUpDownActions(touchDown: touchDown, touchUp: touchUp))
	}
	
	func repeating(interval: TimeInterval = 0.2, action: @escaping () -> Void) -> some View {
		TouchRepeatingView(content: self, interval: interval, action: action)
	}
}
#endif
