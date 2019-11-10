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
