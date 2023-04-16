//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 3/12/23.
//

#if canImport(AppKit)

import AppKit

@available(OSX 10.15, *)
public extension View {
	func closeCurrentWindow() {
		#if targetEnvironment(macCatalyst)
		
		#else
			NSApplication.shared.keyWindow?.close()
		#endif
	}
}

#endif
