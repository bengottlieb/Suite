//
//  NSButton.swift
//  
//
//  Created by ben on 5/3/20.
//

#if canImport(AppKit)

import AppKit

extension NSButton {
	public var isOn: Bool {
		get { return self.state == NSControl.StateValue.on }
		set { self.state = newValue ? NSControl.StateValue.on : NSControl.StateValue.off }
	}
}

#endif
