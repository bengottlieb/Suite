//
//  UIApplication.swift
//  
//
//  Created by ben on 12/14/19.
//

#if canImport(UIKit)

import UIKit

@available(iOS 13.0, *)
public extension UIApplication {
	var currentScene: UIWindowScene? {
		self.connectedScenes
			.filter { $0.activationState == .foregroundActive }
			.compactMap { $0 as? UIWindowScene }
			.first
	}
	
    var currentWindow: UIWindow? {
		self.currentScene?
			.windows
			.first { $0.isKeyWindow }
    }
}

#endif
