//
//  DragContainer.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/14/23.
//

import SwiftUI

@available(OSX 13, iOS 15, tvOS 13, watchOS 8, *)
public struct DragContainer<Content: View>: View {
	@ViewBuilder private var content: () -> Content
	@StateObject private var coordinator = DragCoordinator()
	
	public init(@ViewBuilder content: @escaping () -> Content) {
		self.content = content
	}
	
	public var body: some View {
		ZStack(alignment: .topLeading) {
			content()
			
			if coordinator.isDragging, let image = coordinator.draggedImage, let offset = coordinator.dragOffset {
				Image(dragImage: image)
					.scaleEffect(coordinator.dropScale)
					.id("dragged")
					.offset(offset)
			}
		}
		.environment(\.currentDragPosition, coordinator.currentPosition)
		.environmentObject(coordinator)
		.background {
			GeometryReader { geo in
				Color.clear
					.onAppear {
						coordinator.containerFrame = geo.frame(in: .dragAndDropSpace)
						print("Global: \(geo.frame(in: .global))")
						print("Drag: \(geo.frame(in: .dragAndDropSpace))")
					}
					.onReceive(CoordinateSpace.dragAndDropSpaceCreatedNotification.publisher()) { _ in
						coordinator.containerFrame = geo.frame(in: .dragAndDropSpace)
						print("Updated Global: \(geo.frame(in: .global))")
						print("Updated Drag: \(geo.frame(in: .dragAndDropSpace))")
					}
			}
		}
		.dragAndDropCoordinateSpace()
	}
}

@available(OSX 13, iOS 15, tvOS 13, watchOS 8, *)
struct DragContainer_Previews: PreviewProvider {
	static var previews: some View {
		DragContainer() {
			
		}
	}
}
