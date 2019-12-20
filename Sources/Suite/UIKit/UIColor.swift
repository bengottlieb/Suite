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
		var rgbValue: UInt32 = 0
		
		if hex.hasPrefix("#") { hex = String(hex.dropFirst()) }
		
		if #available(iOS 13.0, *) {
			let rgbInt = Scanner(string: hex).scanInt(representation: .hexadecimal) ?? 0
			rgbValue = UInt32(rgbInt)
		} else {
			Scanner(string: hex).scanHexInt32(&rgbValue)
		}
		
		let red, green, blue: CGFloat
		let max: CGFloat = hex.count == 3 ? 15 : 255
		
		if hex.count == 3 {
			red = CGFloat((rgbValue & 0x000F00) >> 8)
			green = CGFloat((rgbValue & 0x0000F0) >> 4)
			blue = CGFloat(rgbValue & 0x00000F)
		} else {
			red = CGFloat((rgbValue & 0xFF0000) >> 16)
			green = CGFloat((rgbValue & 0x00FF00) >> 8)
			blue = CGFloat(rgbValue & 0x0000FF)
		}
		self.init(red: red / max, green: green / max, blue: blue / max, alpha: 1.0)
	}
}
#endif
