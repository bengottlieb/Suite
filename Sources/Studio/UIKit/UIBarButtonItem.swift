//
//  UIBarButtonItem.swift
//  
//
//  Created by Ben Gottlieb on 2/22/20.
//

#if canImport(UIKit) && !os(watchOS) && !os(visionOS)

import UIKit

extension UIBarButtonItem {
	public convenience init(activityIndicator style: UIActivityIndicatorView.Style, width: CGFloat = 44) {
		let container = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 20))
		let activity = UIActivityIndicatorView(frame: .zero)
			.addAsSubview(of: container)

		activity.translatesAutoresizingMaskIntoConstraints = false
		activity.style = style
		activity.startAnimating()
		container.widthAnchor.constraint(equalToConstant: width).isActive = true
		activity.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
		activity.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
		
		self.init(customView: container)
	}
}

#endif
