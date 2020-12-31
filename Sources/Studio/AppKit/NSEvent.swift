//
//  NSEvent.swift
//  
//
//  Created by Ben Gottlieb on 11/3/20.
//

import Foundation

#if canImport(AppKit)
import AppKit

public extension NSEvent {
	func isModifierKeyDown(_ key: NSEvent.ModifierFlags) -> Bool {
		!self.modifierFlags.intersection(key).isEmpty
	}

	var isShiftKeyDown: Bool { get { self.isModifierKeyDown(.shift) } }
	var isOptionKeyDown: Bool { get { self.isModifierKeyDown(.option) } }
	var isCommandKeyDown: Bool { get { self.isModifierKeyDown(.command) } }
	var isControlKeyDown: Bool { get { self.isModifierKeyDown(.control) } }
	
	
	func location(in view: NSView) -> CGPoint {
		let windowPoint = self.locationInWindow
		let location = view.convert(windowPoint, from: nil)
		return location
	}
}

#endif
