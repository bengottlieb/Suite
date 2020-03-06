//
//  UIColor.swift
//  
//
//  Created by Ben Gottlieb on 12/2/19.
//

#if canImport(UIKit)
import UIKit

public extension UIColor {
	convenience init?(hexString: String?) {
		guard let values = hexString?.extractedHexValues as? [CGFloat] else {
			self.init(white: 0, alpha: 0)
			return nil
		}
		self.init(red: values[0], green: values[1], blue: values[2], alpha: values.count > 3 ? values[3] : 1.0)
	}
}
#else
import Cocoa
#endif

public extension String {
	var extractedHexValues: [Double]? {
		var rgbValue: UInt32 = 0
		var hex = self
		
		if hex.hasPrefix("#") { hex = String(hex.dropFirst()) }
		
		if #available(macOS 10.15, iOS 13.0, *) {
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
