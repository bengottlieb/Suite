//
//  NSAlert.swift
//  
//
//  Created by ben on 5/3/20.
//

import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSAlert {
	public static func showAlert(title: String, message: String, buttonTitles: [String] = [NSLocalizedString("OK", comment: "OK")], style: NSAlert.Style = .informational, in window: NSWindow? = nil, completion: ((Int) -> Void)? = nil) {
		
		DispatchQueue.main.async {
			let alert = NSAlert()
			
			for title in buttonTitles {
				alert.addButton(withTitle: title)
			}
			
			alert.informativeText = message
			alert.messageText = title
			alert.alertStyle = style
			
			alert.show(in: window, completion: completion)
		}
	}
	
	public func show(in window: NSWindow?, completion: ((Int) -> Void)? = nil) {
		let finish = { (response: NSApplication.ModalResponse) in
			switch response {
			case NSApplication.ModalResponse.alertFirstButtonReturn: completion?(0)
			case NSApplication.ModalResponse.alertSecondButtonReturn: completion?(1)
			case NSApplication.ModalResponse.alertThirdButtonReturn: completion?(2)
			default: completion?((response.rawValue - NSApplication.ModalResponse.alertThirdButtonReturn.rawValue) + 3)
			}
		}
		
		DispatchQueue.main.async {
			if let window = window {
				self.beginSheetModal(for: window) { response in
					finish(response)
				}
			} else {
				let response = self.runModal()
				finish(response)
			}
		}
	}
}

#endif
