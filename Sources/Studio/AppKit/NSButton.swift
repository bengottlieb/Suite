//
//  NSButton.swift
//  
//
//  Created by ben on 5/3/20.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

public extension NSButton {
	var isOn: Bool {
		get { return self.state == NSControl.StateValue.on }
		set { self.state = newValue ? NSControl.StateValue.on : NSControl.StateValue.off }
	}
	
	@discardableResult func visiblyEnabled(_ enabled: Bool, disabledAlpha alpha: Float = 0.6) -> Self {
		self.wantsLayer = true
		self.layer?.opacity = enabled ? 1.0 : alpha
		self.isEnabled = enabled
		return self
	}
	
	@discardableResult func bezel(_ bezel: NSButton.BezelStyle) -> Self {
		self.bezelStyle = bezel
		return self
	}
}

#endif
