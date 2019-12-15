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
		guard var hex = hexString else {
			self.init(white: 0, alpha: 0)
			return nil
		}
		if hex.hasPrefix("#") { hex = String(hex.dropFirst()) }
		
		let rgbInt = Scanner(string: hex).scanInt(representation: .hexadecimal) ?? 0
		let rgbValue = UInt32(rgbInt)
		let red = CGFloat((rgbValue & 0xFF0000) >> 16)
		let green = CGFloat((rgbValue & 0x00FF00) >> 8)
		let blue = CGFloat(rgbValue & 0x0000FF)

		self.init(red: CGFloat(red / 255.0), green: CGFloat(green / 255.0), blue: CGFloat(blue / 255.0), alpha: 1.0)		
	}
}
#endif
