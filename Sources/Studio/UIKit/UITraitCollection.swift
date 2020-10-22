//
//  UITraitCollection.swift
//  
//
//  Created by ben on 4/16/20.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

public extension UITraitCollection {
	var isInDarkMode: Bool {
		if #available(iOS 12.0, *) {
			return self.userInterfaceStyle == .dark
		} else {
			return false
		}
	}
}

#endif
