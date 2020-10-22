//
//  UIControl.swift
//  
//
//  Created by ben on 12/16/19.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

public extension UIControl {
	@discardableResult func add(target: Any?, action: Selector, for controlEvents: UIControl.Event) -> Self {
		self.addTarget(target, action: action, for: controlEvents)
		return self
	}
}
#endif
