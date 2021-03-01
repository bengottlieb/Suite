//
//  ErrorHandling.swift
//  
//
//  Created by ben on 9/17/19.
//

import Foundation

public extension Error {
    var isOffline: Bool {
        if let httpError = self as? HTTPError, httpError.isOffline { return true }
        return (self as NSError).code == -1009
    }
}

public extension Array where Element == Error {
    var isOffline: Bool {
        !isEmpty && self.count == self.filter { $0.isOffline }.count
    }
}

#if !canImport(UIKit)
	import Cocoa

	extension Error {
		public func display(in window: NSWindow? = nil, title: String? = nil, message: String? = nil, buttons: [String]? = nil, completion: ((Int) -> Void)? = nil) {
			let alert = NSAlert(error: self)
			
			if let title = title {
				alert.messageText = title
				alert.informativeText = message ?? self.localizedDescription
			}
			
			if let buttons = buttons {
				buttons.forEach { button in
					alert.addButton(withTitle: button)
				}
			} else {
				alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
			}
			
			if let win = window {
				alert.beginSheetModal(for: win) { result in
					if result == NSApplication.ModalResponse.alertFirstButtonReturn { completion?(0) }
					if result == NSApplication.ModalResponse.alertSecondButtonReturn { completion?(1) }
					if result == NSApplication.ModalResponse.alertThirdButtonReturn { completion?(2) }
				}
			} else {
				let result = alert.runModal()
				if result == NSApplication.ModalResponse.alertFirstButtonReturn { completion?(0) }
				if result == NSApplication.ModalResponse.alertSecondButtonReturn { completion?(1) }
				if result == NSApplication.ModalResponse.alertThirdButtonReturn { completion?(2) }
			}
		}
	}

#endif
