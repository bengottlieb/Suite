//
//  tapGestures.swift
//  
//
//  Created by Ben Gottlieb on 5/8/23.
//

import SwiftUI

@available(macOS 10.15, iOS 13.0, watchOS 7.0, *)
public extension View {
	func tapGestureWithLocation(_ tap: @escaping (CGPoint) -> Void) -> some View {
		self
			.gesture (
				DragGesture(minimumDistance: 0, coordinateSpace: .local)
					.onEnded { info in
						tap(info.location)
					}
			)
	}

	func dragGestureWithLocation(_ drag: @escaping (CGPoint) -> Void) -> some View {
		self
			.gesture (
				DragGesture(minimumDistance: 0, coordinateSpace: .local)
					.onChanged { info in
						drag(info.location)
					}
			)
	}

}
