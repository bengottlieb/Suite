//
//  UILabel.swift
//  
//
//  Created by ben on 11/29/19.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

public extension UILabel {
	@discardableResult func text(_ text: String?) -> Self {
		self.text = text
		return self
	}
	
	@discardableResult func attributedText(_ attributedText: NSAttributedString?) -> Self {
		self.attributedText = attributedText
		return self
	}

	@discardableResult func font(_ font: UIFont) -> Self {
		self.font = font
		return self
	}
	
	@discardableResult func textColor(_ textColor: UIColor) -> Self {
		self.textColor = textColor
		return self
	}
	
	@discardableResult func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
		self.textAlignment = textAlignment
		return self
	}
	
	@discardableResult func lineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
		self.lineBreakMode = lineBreakMode
		return self
	}
	
	@discardableResult func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> Self {
		self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
		return self
	}
	
	@discardableResult func minimumScaleFactor(_ minimumScaleFactor: CGFloat) -> Self {
		self.minimumScaleFactor = minimumScaleFactor
		return self
	}
	
	@discardableResult func numberOfLines(_ numberOfLines: Int) -> Self {
		self.numberOfLines = numberOfLines
		return self
	}
}

#endif
