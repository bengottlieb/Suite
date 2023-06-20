//
//  NSView.swift
//  
//
//  Created by Ben Gottlieb on 2/22/23.
//

#if os(macOS)

import Cocoa
import AppKit

public extension NSView {
	@discardableResult
	func add<T: NSView>(subview: T) -> T {
		self.addSubview(subview)
		return subview
	}
	
	@discardableResult func addAsSubview(of superview: NSView, fullSize: Bool = false) -> Self {
		if let stackView = superview as? NSStackView {
			stackView.addArrangedSubview(self)
		} else {
			superview.addSubview(self)
			if fullSize {
				self.frame = superview.bounds
				self.autoresizingMask = [.width, .height]
			}
		}
		return self
	}
	
	@discardableResult func autoresizingMask(_ mask: NSView.AutoresizingMask) -> Self {
		self.autoresizingMask = mask
		return self
	}
	
	@discardableResult func transform(_ transform: CATransform3D) -> Self {
		self.wantsLayer = true
		self.layer?.transform = transform
		return self
	}
	
	@discardableResult func translatedBy(_ point: CGPoint) -> Self {
		self.transform(CATransform3DMakeTranslation(point.x, point.y, 0))
	}
	
	@discardableResult func rotatedBy(radians angle: CGFloat) -> Self {
		self.transform(CATransform3DMakeRotation(angle, 0, 0, 1))
	}
	
	@discardableResult func rotatedBy(degrees angle: CGFloat) -> Self {
		rotatedBy(radians: (angle * .pi * 2) / 360)
	}
	
	@discardableResult func roundCorners(to radius: CGFloat?) -> Self {
		self.wantsLayer = true
		self.layer?.cornerRadius = radius ?? self.bounds.height / 2
		self.layer?.masksToBounds = true
		return self
	}
	
	@discardableResult func translatesAutoresizingMaskIntoConstraints(_ translate: Bool) -> Self {
		translatesAutoresizingMaskIntoConstraints = translate
		return self
	}
	
	@discardableResult func backgroundColor(_ backgroundColor: NSColor?) -> Self {
		self.wantsLayer = true
		self.layer?.backgroundColor = backgroundColor?.cgColor
		return self
	}
	
	@discardableResult func alpha(_ alpha: Float) -> Self {
		self.wantsLayer = true
		self.layer?.opacity = alpha
		return self
	}
	
	@discardableResult func isHidden(_ hidden: Bool) -> Self {
		self.isHidden = hidden
		return self
	}
	
	@discardableResult func clipsToBounds(_ clipsToBounds: Bool) -> Self {
		self.wantsLayer = true
		self.layer?.masksToBounds = clipsToBounds
		return self
	}
	
//	@discardableResult func contentHuggingPriority(_ priority: NSLayoutConstraint.Priority, for axis: NSLayoutConstraint.Axis) -> Self {
//		self.setContentHuggingPriority(priority, for: axis)
//		return self
//	}
//	
//	@discardableResult func contentCompressionResistancePriority(_ priority: NSLayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
//		self.setContentCompressionResistancePriority(priority, for: axis)
//		return self
//	}
	
	@discardableResult func frame(_ rect: CGRect) -> Self {
		self.frame = rect
		return self
	}

	@discardableResult func border(_ width: CGFloat, color: NSColor) -> Self {
		self.wantsLayer = true
		self.layer?.borderColor = color.cgColor
		self.layer?.borderWidth = width
		return self
	}
	
	func fullyConstrain(to view: NSView) {
		translatesAutoresizingMaskIntoConstraints = false
		addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0))
		addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 23))
		addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0))
		addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0))
	}
}


#endif
