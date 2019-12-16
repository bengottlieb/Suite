//
//  File.swift
//  
//
//  Created by ben on 12/16/19.
//

import UIKit

public extension UIAlertController {
	convenience init(title: String, message: String?, button: String = NSLocalizedString("OK", comment: "OK")) {
		self.init(title: title, message: message, preferredStyle: .alert)
		
		self.addAction(UIAlertAction(title: button, style: .cancel, handler: nil))
	}
}
