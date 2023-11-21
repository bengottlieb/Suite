//
//  UIButton.swift
//  
//
//  Created by ben on 11/29/19.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit


public extension UIButton {
	@discardableResult func isEnabled(_ enabled: Bool) -> Self {
		self.isEnabled = enabled
		return self
	}
	
	@discardableResult func visiblyEnabled(_ enabled: Bool, disabledAlpha alpha: CGFloat = 0.5) -> Self {
		self.alpha = enabled ? 1.0 : alpha
		self.isEnabled = enabled
		return self
	}
	
	@discardableResult func title(_ title: String?, for state: UIControl.State = .normal) -> Self {
		setTitle(title, for: state)
		return self
	}
	
	@discardableResult func titleColor(_ titleColor: UIColor?, for state: UIControl.State = .normal) -> Self {
		setTitleColor(titleColor, for: state)
		return self
	}
	
	@discardableResult func attributedTitle(_ attributedTitle: NSAttributedString?, for state: UIControl.State = .normal) -> Self {
		setAttributedTitle(attributedTitle, for: state)
		return self
	}
	
	@discardableResult func font(_ font: UIFont) -> Self {
		self.titleLabel?.font = font
		return self
	}
	
	@discardableResult func image(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
		setImage(image, for: state)
		return self
	}
	
	@discardableResult func backgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State = .normal) -> Self {
		setBackgroundImage(backgroundImage, for: .normal)
		return self
	}
	
	@discardableResult func showsTouchWhenHighlighted(_ shows: Bool) -> Self {
		#if !os(visionOS)
			self.showsTouchWhenHighlighted = shows
		#endif
		return self
	}
}
#endif
