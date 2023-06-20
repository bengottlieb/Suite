//
//  NSImage.swift
//  
//
//  Created by Ben Gottlieb on 12/2/19.
//


#if canImport(Cocoa) && !targetEnvironment(macCatalyst)
import Cocoa
import AppKit

public extension NSImage {
	func scaledImage(newSize: CGSize) -> NSImage? {
		let size: CGSize = self.size
		let targetSize = size.scaled(within: newSize)
		let result = NSImage(size: targetSize)

		result.lockFocus()
		self.draw(in: targetSize.rect)
		result.unlockFocus()

		return result
	}
	
	func resized(to size: CGSize, trimmed: Bool = true, changeScaleTo: CGFloat? = nil) -> NSImage? {
		var frame = self.size.rect.within(limit: size.rect, placed: .scaleAspectFit).rounded()
		
		
		if frame.origin.x > 0 {
			if (!trimmed) {
				let bump = size.height * (frame.origin.x / frame.width)
				frame.origin.y -= bump
				frame.size.height += bump * 2
			}
			frame.origin.x = 0;
			frame.size.width = size.width;
		} else {
			if (!trimmed) {
				let bump = size.width * (frame.origin.y / frame.height)
				frame.origin.x -= bump
				frame.size.width += bump * 2
			}
			frame.origin.y = 0;
		}
		
		let result = NSImage(size: size)
		result.lockFocus()
		self.draw(in: frame)
		result.unlockFocus()
		
		return result
	}

}
#endif
