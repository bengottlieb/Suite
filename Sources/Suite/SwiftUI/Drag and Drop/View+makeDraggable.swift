//
//  View+DragContainer.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/14/23.
//

import SwiftUI

@available(OSX 13, iOS 16, tvOS 13, watchOS 8, *)
public extension View {
	func makeDraggable(type: String, object: Any, hideWhenDragging: Bool = true) -> some View {
		DraggableView(content: self, type: type, object: object, hideWhenDragging: hideWhenDragging)
	}
}

@available(OSX 13, iOS 16, tvOS 13, watchOS 8, *)
struct DraggableView<Content: View>: View {
	let content: Content
	let type: String
	let object: Any
	let hideWhenDragging: Bool
	
	@EnvironmentObject var dragCoordinator: DragCoordinator
	@Environment(\.isDragAndDropEnabled) var isDragAndDropEnabled
	@State var frame: CGRect?
	@State var isDragging = false
	var dragAlpha: CGFloat { hideWhenDragging ? 0 : 0.25 }

	var body: some View {
		if isDragAndDropEnabled {
			content
				.gesture(dragGesture)
				.opacity(isDragging ? dragAlpha : 1)
				.reportGeometry(frame: $frame, in: .dragAndDropSpace)
		} else {
			content
		}
	}
	
	@ViewBuilder func dragContent() -> some View {
		content
	}
	
	private var dragGesture: some Gesture {
		DragGesture(coordinateSpace: .dragAndDropSpace).onChanged { action in
			if !isDragging {
				isDragging = true
				let renderer = ImageRenderer(content: dragContent())
				dragCoordinator.startDragging(at: action.location, source: frame, type: type, object: object, image: renderer.dragImage)
			}
			dragCoordinator.currentPosition = action.location
		}
		.onEnded { action in
			isDragging = false
			dragCoordinator.drop(at: action.location)
		}
	}
}
