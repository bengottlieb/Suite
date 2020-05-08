//
//  NSColor.swift
//  
//
//  Created by ben on 5/3/20.
//

import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit


public extension NSColor {
	convenience init?(hex hexString: String?) {
		guard let values = hexString?.extractedHexValues else {
			self.init(white: 0, alpha: 0)
			return nil
		}
		self.init(red: CGFloat(values[0]), green: CGFloat(values[1]), blue: CGFloat(values[2]), alpha: CGFloat(values.count > 3 ? values[3] : 1.0))
	}
	
	convenience init(red: Int, green: Int, blue: Int, alpha: Double = 1.0) {
		self.init(red: CGFloat(red.capped(0...255)) / 255.0, green: CGFloat(green.capped(0...255)) / 255.0, blue: CGFloat(blue.capped(0...255)) / 255.0, alpha: CGFloat(alpha))
	}
	
	convenience init(hex: Int, alpha: Double = 1.0) {
		self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF, alpha: alpha)
	}
	
	var hexString: String {
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		
		self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		
		let r = Int(255.0 * red)
		let g = Int(255.0 * green)
		let b = Int(255.0 * blue)
		
		return String(format: "%02x%02x%02x", arguments: [r, g, b])
	}

	var hex: Int {
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		
		self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		
		let r = Int(255.0 * red)
		let g = Int(255.0 * green)
		let b = Int(255.0 * blue)
		
		return r << 16 + g << 8 + b
	}
}

#endif
