//
//  UIColor.swift
//  
//
//  Created by Ben Gottlieb on 12/2/19.
//

import Foundation

#if canImport(UIKit)
import UIKit

public extension UIColor {
	static func random() -> UIColor {
		let h = CGFloat.random(in: 0...1)
		let s = CGFloat.random(in: 0...1)
		let v = CGFloat.random(in: 0...1)
		
		return UIColor(hue: h, saturation: s, brightness: v, alpha: 1)
	}
	
	var brightness: Double {
		var r: CGFloat = 0.0
		var g: CGFloat = 0.0
		var b: CGFloat = 0.0
		var a: CGFloat = 0.0
		var brightness: CGFloat = 0.0
		
		//guard let rgb = usingColorSpace(.sRGB) else { return 0.5 }
		self.getRed(&r, green: &g, blue: &b, alpha: &a)

		// algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
		brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000;
		return brightness
	}
	
	convenience init?(hex hexString: String?) {
		guard let values = hexString?.extractedHexValues else {
			self.init(white: 0, alpha: 0)
			return nil
		}
		self.init(red: CGFloat(values[0]), green: CGFloat(values[1]), blue: CGFloat(values[2]), alpha: CGFloat(values.count > 3 ? values[3] : 1.0))
	}
	
	convenience init(r: Int, g: Int, b: Int, a: Double = 1.0) {
		self.init(red: CGFloat(r.capped(0...255)) / 255.0, green: CGFloat(g.capped(0...255)) / 255.0, blue: CGFloat(b.capped(0...255)) / 255.0, alpha: CGFloat(a))
	}
	
	convenience init(hex: Int, alpha: Double = 1.0) {
		self.init(r: (hex >> 16) & 0xFF, g: (hex >> 8) & 0xFF, b: hex & 0xFF, a: alpha)
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
	
	func alpha(_ alpha: CGFloat) -> UIColor {
		self.withAlphaComponent(alpha)
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
	
	static var defaultText: UIColor {
		#if os(watchOS)
			return .darkGray
		#else
			if #available(iOS 13.0, *) {
				return UIColor.label
			} else {
				return UIColor.black
			}
		#endif
	}
	
	static var secondaryText: UIColor {
		#if os(watchOS)
			return .white
		#else
			if #available(iOS 13.0, *) {
				return UIColor.secondaryLabel
			} else {
				return UIColor.darkGray
			}
		#endif
	}
	
	static var tertiaryText: UIColor {
		#if os(watchOS)
			return .lightGray
		#else
			if #available(iOS 13.0, *) {
				return UIColor.tertiaryLabel
			} else {
				return UIColor.lightGray
			}
		#endif
	}
	
	static var defaultBackground: UIColor {
		#if os(watchOS)
			return .white
		#else
			if #available(iOS 13.0, *) {
				return UIColor.systemBackground
			} else {
				return UIColor.white
			}
		#endif
	}
	
	#if os(iOS)
		@available(iOS 10.0, *)
		func swatch(of size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
			UIGraphicsImageRenderer(size: size).image { ctx in
				self.setFill()
				UIRectFill(size.rect)
			}
		}
	#endif
}
#else
#if canImport(Cocoa)
	import Cocoa
#endif
#endif

public extension Int {
	
}

public extension String {
	var extractedHexValues: [Double]? {
		var rgbValue: UInt32 = 0
		var hex = self
		
		if hex.hasPrefix("#") { hex = String(hex.dropFirst()) }
		
		if #available(macOS 10.15, iOS 13.0, watchOS 6.0, *) {
			let rgbInt = Scanner(string: hex).scanInt(representation: .hexadecimal) ?? 0
			rgbValue = UInt32(rgbInt)
		} else {
			Scanner(string: hex).scanHexInt32(&rgbValue)
		}
		
		if hex.count == 3 {
			return [
				Double((rgbValue & 0x000F00) >> 8) / 15,
				Double((rgbValue & 0x0000F0) >> 4) / 15,
				Double(rgbValue & 0x00000F) / 15,
			]
		}
		
		if hex.count == 4 {
			return [
				Double((rgbValue & 0x000F00) >> 12) / 15,
				Double((rgbValue & 0x000F00) >> 8) / 15,
				Double((rgbValue & 0x0000F0) >> 4) / 15,
				Double(rgbValue & 0x00000F),
			]
		}
		
		if hex.count == 6 {
			return [
				Double((rgbValue & 0xFF0000) >> 16) / 255,
				Double((rgbValue & 0x00FF00) >> 8) / 255,
				Double(rgbValue & 0x0000FF) / 255
			]
		}

		if hex.count == 8 {
			return [
				Double((rgbValue & 0xFF0000) >> 24) / 255,
				Double((rgbValue & 0xFF0000) >> 16) / 255,
				Double((rgbValue & 0x00FF00) >> 8) / 255,
				Double(rgbValue & 0x0000FF) / 255
			]
		}
		return nil
	}
}
