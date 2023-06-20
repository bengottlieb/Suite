//
//  NSTextFieldAndView.swift
//  
//
//  Created by Ben Gottlieb on 2/28/23.
//

#if os(macOS)
import Cocoa
import AppKit

public extension NSTextView {
	@discardableResult func attributedString(_ string: NSAttributedString) -> Self {
		textStorage?.setAttributedString(string)
		return self
	}
	
	
}

public extension NSTextField {
	@discardableResult func attributedString(_ string: NSAttributedString) -> Self {
		self.attributedStringValue = string
		return self
	}
	
	@discardableResult func lineBreakMode(_ mode: NSLineBreakMode) -> Self {
		self.lineBreakMode = mode
		return self
	}
	
	@discardableResult func maximumNumberOfLines(_ count: Int) -> Self {
		self.maximumNumberOfLines = count
		return self
	}
	
	@discardableResult func selectable(_ select: Bool) -> Self {
		self.isSelectable = select
		return self
	}
	
	@discardableResult func editabled(_ editable: Bool) -> Self {
		self.isEditable = editable
		return self
	}
	
	@discardableResult func bordered(_ border: Bool) -> Self {
		self.isBordered = border
		return self
	}
	
	
}


#endif
