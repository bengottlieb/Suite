//
//  View+URL.swift
//  
//
//  Created by ben on 3/23/20.
//

#if canImport(Combine)
#if canImport(UIKit) && !os(watchOS)

import SwiftUI
import SafariServices
import UIKit

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
@available(iOSApplicationExtension, unavailable)
public extension View {
	func display(url: URL, inSafari: Bool = false) {
		if inSafari {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
			return
		}
		
		guard let controller = self.enclosingRootViewController else { return }
		let safariController = SFSafariViewController(url: url)
		
		controller.present(safariController, animated: true, completion: nil)
	}
}

#endif
#endif
