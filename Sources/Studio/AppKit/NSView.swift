//
//  NSView.swift
//  
//
//  Created by ben on 5/3/20.
//

import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

public extension NSView {
	var backgroundColor: NSColor? {
		set { self.wantsLayer = true; self.layer?.backgroundColor = newValue?.cgColor }
		get { if let color = self.layer?.backgroundColor { return NSColor(cgColor: color) }; return nil }
	}

	var isInDarkMode: Bool {
		if #available(OSX 10.14, OSXApplicationExtension 10.14, *) {
			let appearance = self.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua])
			return appearance == .darkAqua
		} else {
			return false
		}
	}
}

#endif
