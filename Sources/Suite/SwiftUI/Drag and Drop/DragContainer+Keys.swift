//
//  DragContainer+Environment.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/14/23.
//

import SwiftUI

#if os(macOS)
	typealias DragImage = NSImage
	extension Image {
		init(dragImage: DragImage) { self.init(nsImage: dragImage) }
	}
	@available(OSX 13, iOS 16, tvOS 13, watchOS 8, *)
	extension ImageRenderer {
		@MainActor var dragImage: NSImage? { nsImage }
	}
#else
	typealias DragImage = UIImage
	@available(OSX 13, iOS 16, tvOS 13, watchOS 8, *)
	extension Image {
		init(dragImage: DragImage) { self.init(uiImage: dragImage) }
	}
	@available(OSX 13, iOS 16, tvOS 13, watchOS 9, *)
	extension ImageRenderer {
		@MainActor var dragImage: UIImage? { uiImage }
	}
#endif



@available(OSX 13, iOS 15, tvOS 13, watchOS 8, *)
struct CurrentDragPositionEnvironmentKey: EnvironmentKey {
	static var defaultValue: CGPoint?
}

@available(OSX 13, iOS 15, tvOS 13, watchOS 8, *)
struct DragAndDropEnabledEnvironmentKey: EnvironmentKey {
	static var defaultValue = false
}

@available(OSX 13, iOS 15, tvOS 13, watchOS 8, *)
extension EnvironmentValues {
	public var currentDragPosition: CGPoint? {
		get { self[CurrentDragPositionEnvironmentKey.self] }
		set { self[CurrentDragPositionEnvironmentKey.self] = newValue }
	}

	public var isDragAndDropEnabled: Bool {
		get { self[DragAndDropEnabledEnvironmentKey.self] }
		set { self[DragAndDropEnabledEnvironmentKey.self] = newValue }
	}

	
}
