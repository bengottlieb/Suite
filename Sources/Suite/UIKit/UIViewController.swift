//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 12/1/19.
//

#if canImport(UIKit)
import UIKit

public extension UIViewController {
	@discardableResult
	func turnOffCardModalPresentation() -> Self {
		 if #available(iOS 13.0, iOSApplicationExtension 13.0, *) {
			  self.isModalInPresentation = false
		 }
		 return self
	}
	
	var presentedest: UIViewController {
		return self.presentedViewController?.presentedest ?? self
	}
}
#endif
