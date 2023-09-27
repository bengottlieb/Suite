//
//  PositionedLongPressGesture.swift
//  
//
//  Created by Ben Gottlieb on 4/10/23.
//

import SwiftUI

#if os(iOS) && !os(xrOS)
let feedbackEngine = UIImpactFeedbackGenerator(style: .heavy)

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public extension View {
	func positionedLongPressGesture(duration: TimeInterval = 1.0, maxDistance: Double = 0, playFeedback: Bool = true, completion: @escaping (CGPoint) -> Void) -> some View {
		self
			.modifier(PositionedLongPressGesture(duration: duration, maxDistance: maxDistance, playFeedback: playFeedback, completion: completion))
	}
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
struct PositionedLongPressGesture: ViewModifier {
	@State private var location: CGPoint?
	@State private var timer: Timer?
	let longPressDuration: TimeInterval
	let maxDistance: Double
	let playFeedback: Bool
	var completion: (CGPoint) -> Void

	init(duration: TimeInterval = 0.6, maxDistance: Double = 0, playFeedback: Bool, completion: @escaping (CGPoint) -> Void) {
		self.longPressDuration = duration
		self.completion = completion
		self.maxDistance = maxDistance
		self.playFeedback = playFeedback
	}
	
	func body(content: Content) -> some View {
			content
				.contentShape(Rectangle())
				.gesture(
					DragGesture(minimumDistance: maxDistance, coordinateSpace: .global)
						.onChanged { info in
							if location == nil {
								location = info.location
								timer = Timer.scheduledTimer(withTimeInterval: longPressDuration, repeats: false) { _ in
									if let location {
										feedbackEngine.impactOccurred()
										if playFeedback { completion(location) }
									}
									timer = nil
								}
							}
							
							if info.translation.largestDimension > 10 { timer?.invalidate() }
						}
						.onEnded { _ in
							timer?.invalidate()
							timer = nil
							location = nil
						}

				)
			
	}
}
#endif
