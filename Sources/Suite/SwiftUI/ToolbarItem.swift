//
//  ToolbarItem.swift
//
//
//  Created by Ben Gottlieb on 9/20/23.
//

import SwiftUI

@available(iOS 14.0, macOS 13.0, *)
public extension ToolbarItemPlacement {
	#if os(iOS)
		static let `default`: ToolbarItemPlacement = .bottomBar
	#else
		static let `default`: ToolbarItemPlacement = .automatic
	#endif
}
