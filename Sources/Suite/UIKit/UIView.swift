//
//  UIView.swift
//  
//
//  Created by Ben Gottlieb on 11/9/19.
//

import UIKit

public extension UIView {
	var viewController: UIViewController? {
		var responder = self.next
		
		while responder != nil {
			if let controller = responder as? UIViewController { return controller }
			responder = responder!.next
		}
		
		return nil
	}
	
	static let activityIndicatorTag = 10246
	
	@discardableResult
	func addActivityView(color: UIColor = .white) -> UIActivityIndicatorView {
		if let spinner = self.viewWithTag(UIView.activityIndicatorTag) as? UIActivityIndicatorView {
			spinner.color = color
			return spinner
		}
		
		let spinner = UIActivityIndicatorView(style: .white)
		spinner.color = color
		spinner.tag = UIView.activityIndicatorTag
		spinner.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(spinner)
		self.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
		self.centerYAnchor.constraint(equalTo: spinner.centerYAnchor).isActive = true
		spinner.startAnimating()
		
		if let button = self as? UIButton {
			button.titleLabel?.alpha = 0.2
		}
		
		return spinner
	}
	
	func removeActivityView() {
		(self.viewWithTag(UIView.activityIndicatorTag) as? UIActivityIndicatorView)?.removeFromSuperview()
		if let button = self as? UIButton {
			button.titleLabel?.alpha = 1
		}
	}
}

public extension UIView {
	@discardableResult func addAsSubview(of superview: UIView) -> Self {
		if let stackView = superview as? UIStackView {
			stackView.addArrangedSubview(self)
		} else {
			superview.addSubview(self)
		}
		return self
	}
	
	@discardableResult func autoresizingMask(_ mask: UIView.AutoresizingMask) -> Self {
		self.autoresizingMask = mask
		return self
	}
	
	@discardableResult func transform(_ transform: CGAffineTransform) -> Self {
		self.transform = transform
		return self
	}
	
	@discardableResult func translatedBy(_ point: CGPoint) -> Self {
		self.transform(CGAffineTransform(translationX: point.x, y: point.y))
	}
	
	@discardableResult func rotatedBy(radians angle: CGFloat) -> Self {
		self.transform(CGAffineTransform(rotationAngle: angle))
	}
	
	@discardableResult func rotatedBy(degrees angle: CGFloat) -> Self {
		self.transform(CGAffineTransform(rotationAngle: (angle * .pi * 2) / 360))
	}
	
	@discardableResult func roundCorners(to radius: CGFloat?) -> Self {
		self.layer.cornerRadius = radius ?? self.bounds.height / 2
		self.layer.masksToBounds = true
		return self
	}
	
	@discardableResult func backgroundColor(_ backgroundColor: UIColor?) -> Self {
		self.backgroundColor = backgroundColor
		return self
	}
	
	@discardableResult func alpha(_ alpha: CGFloat) -> Self {
		self.alpha = alpha
		return self
	}
	
	@discardableResult func isHidden(_ hidden: Bool) -> Self {
		self.isHidden = hidden
		return self
	}
	
	@discardableResult func isUserInteractionEnabled(_ enabled: Bool) -> Self {
		self.isUserInteractionEnabled = enabled
		return self
	}
	
	@discardableResult func clipsToBounds(_ clipsToBounds: Bool) -> Self {
		self.clipsToBounds = clipsToBounds
		return self
	}
	
	@discardableResult func contentMode(_ mode: UIView.ContentMode) -> Self {
		self.contentMode = mode
		return self
	}
	
	@discardableResult func tag(_ tag: Int) -> Self {
		self.tag = tag
		return self
	}
	
	@discardableResult func contentHuggingPriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
		self.setContentHuggingPriority(priority, for: axis)
		return self
	}
	
	@discardableResult func contentCompressionResistancePriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
		self.setContentCompressionResistancePriority(priority, for: axis)
		return self
	}
	
	@discardableResult func tintColor(_ tintColor: UIColor) -> Self {
		self.tintColor = tintColor
		return self
	}
	
}
