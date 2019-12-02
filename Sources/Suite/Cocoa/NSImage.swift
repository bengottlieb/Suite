//
//  NSImage.swift
//  
//
//  Created by Ben Gottlieb on 12/2/19.
//


#if canImport(Cocoa)
import Cocoa

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
	
	func resizedImage(size: CGSize, trimmed: Bool = true) -> NSImage? {
		let size: CGSize = self.size
		var frame = size.rect.within(limit: size.rect, placed: .scaleAspectFit).round()
		
		
		if frame.origin.x > 0 {
			frame.origin.x = 0;
			if (!trimmed) { frame.size.width = size.width; }
		} else {
			frame.origin.y = 0;
			if (!trimmed) { frame.size.height = size.height; }
		}
		
		let result = NSImage(size: frame.size)
		result.lockFocus()
		self.draw(in: frame)
		result.unlockFocus()
		
		return result
	}

}
#endif
