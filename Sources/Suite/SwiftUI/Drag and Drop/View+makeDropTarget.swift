//
//  View+makeDropTarget.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/14/23.
//

import SwiftUI

@available(OSX 13, iOS 15, tvOS 13, watchOS 8, *)
public extension View {
	func makeDropTarget(types: [String], hover: @escaping (String, Any, CGPoint?) -> Bool = { _, _, _ in true }, dropped: @escaping (String, Any, CGPoint) -> Bool) -> some View {
		DropTargetView(content: self, types: types, hover: hover, dropped: dropped)
	}
}

@available(OSX 13, iOS 15, tvOS 13, watchOS 8, *)
struct DropTargetView<Content: View>: View {
	let content: Content
	let types: [String]
	let hover: (String, Any, CGPoint?) -> Bool
	let dropped: (String, Any, CGPoint) -> Bool

	@EnvironmentObject var dragCoordinator: DragCoordinator
	@State var frame: CGRect?
	@State var indicateIsDropTarget = false
	@State var isDropTarget = false

	var body: some View {
		content
			.background {
				GeometryReader { geo in
					Color.clear
						.onAppear { frame = geo.frame(in: .global) }
				}
				.border(Color.red, width: indicateIsDropTarget ? 4 : 0)
			}
			.onChange(of: dragCoordinator.currentPosition) { newPosition in
				guard let type = dragCoordinator.dragType, let object = dragCoordinator.draggedObject else { return }
				
				if let point = dropPosition(at: newPosition) {
					isDropTarget = true
					indicateIsDropTarget = hover(type, object, point)
				} else if isDropTarget {
					_ = hover(type, object, nil)
					isDropTarget = false
					indicateIsDropTarget = false
				}
			}
			.onChange(of: dragCoordinator.dropPosition) { dropPoint in
				guard let dropPoint else { return }
				if let point = dropPosition(at: dropPoint), let type = dragCoordinator.dragType, let object = dragCoordinator.draggedObject {
					if dropped(type, object, point) {
						dragCoordinator.acceptedDrop = true
					}
				}
			}
	}

	func dropPosition(at point: CGPoint?) -> CGPoint? {
		guard let newPosition = point, let frame else { return nil }
		let relativePoint = CGPoint(x: newPosition.x - frame.minX, y: newPosition.y - frame.minY)
		
		if
			let type = dragCoordinator.dragType,
			types.contains(type),
			frame.contains(newPosition) {
			return relativePoint
		} else {
			return nil
		}
	}

	@ViewBuilder func dragContent() -> some View {
		content
	}
}
