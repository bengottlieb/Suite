//
//  UIScene.swift
//  
//
//  Created by ben on 3/22/20.
//

#if canImport(UIKit)

import UIKit

@available(iOS 13.0, *)
public extension UIWindowScene {
	var frontWindow: UIWindow? {
		if let window = self.windows.first(where: { $0.isKeyWindow }) { return window }
		return self.windows.first
	}
}

#endif

