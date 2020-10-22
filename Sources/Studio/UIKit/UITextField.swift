//
//  UITextField.swift
//  
//
//  Created by Ben Gottlieb on 12/1/19.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

public extension UITextField {
	@discardableResult func text(_ text: String?) -> Self {
		self.text = text
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
	
	@discardableResult func attributedText(_ attributedText: NSAttributedString) -> Self {
		self.attributedText = attributedText
		return self
	}
	
	@discardableResult func placeholder(_ placeholder: String?) -> Self {
		self.placeholder = placeholder
		return self
	}
	
	@discardableResult func attributedPlaceholder(_ attributedPlaceholder: NSAttributedString?) -> Self {
		self.attributedPlaceholder = attributedPlaceholder
		return self
	}
	
	@discardableResult func isSecureTextEntry(_ isSecureTextEntry: Bool) -> Self {
		self.isSecureTextEntry = isSecureTextEntry
		return self
	}
	
	@discardableResult func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
		self.keyboardType = keyboardType
		return self
	}
	
	@discardableResult func autocapitalizationType(_ autocapitalizationType: UITextAutocapitalizationType) -> Self {
		self.autocapitalizationType = autocapitalizationType
		return self
	}
	
	@discardableResult func autocorrectionType(_ autocorrectionType: UITextAutocorrectionType) -> Self {
		self.autocorrectionType = autocorrectionType
		return self
	}
	
	@discardableResult func contentVerticalAlignment(_ contentVerticalAlignment: UIControl.ContentVerticalAlignment) -> Self {
		self.contentVerticalAlignment = contentVerticalAlignment
		return self
	}
	
	@discardableResult func isEnabled(_ enabled: Bool) -> Self {
		self.isEnabled = enabled
		return self
	}
	
	@discardableResult func clearButtonMode(_ clearButtonMode: UITextField.ViewMode) -> Self {
		self.clearButtonMode = clearButtonMode
		return self
	}
	
	@discardableResult func target(_ target: Any?, action: Selector, for controlEvents: UIControl.Event = .editingChanged) -> Self {
		self.addTarget(target, action: action, for: controlEvents)
		return self
	}
	
	@discardableResult func delegate(_ delegate: UITextFieldDelegate?) -> Self {
		self.delegate = delegate
		return self
	}
	
	@discardableResult func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
		self.returnKeyType = returnKeyType
		return self
	}
}

#endif
