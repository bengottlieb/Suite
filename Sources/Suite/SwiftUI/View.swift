//
//  View.swift
//  
//
//  Created by ben on 4/5/20.
//

#if canImport(SwiftUI)
#if canImport(Combine)

import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension View {
    #if os(iOS)
	func toImage() -> UIImage? {
		let controller = UIHostingController(rootView: self.edgesIgnoringSafeArea(.all))
		let view = controller.view

		let targetSize = controller.view.intrinsicContentSize
		view?.bounds = CGRect(origin: .zero, size: targetSize)
		view?.backgroundColor = .clear

		let renderer = UIGraphicsImageRenderer(size: targetSize)

		let image = renderer.image { _ in
			 view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
		}
//		window.removeFromSuperview()
		return image
	}
    #endif

	func frame(size: CGSize) -> some View {
		frame(width: size.width, height: size.height)
	}
	
	func frame(_ size: CGFloat) -> some View {
		frame(width: size, height: size)
	}
	
	func anyView() -> AnyView {
		AnyView(self)
	}
}

#if canImport(UIKit) && !os(watchOS)
import UIKit

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
@available(iOSApplicationExtension, unavailable)
public extension View {
	func resignFirstResponder() {
        UIView.resignAllFirstResponders()
	}
}
#endif

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension View {
	@ViewBuilder func `if`<T>(_ condition: Bool, _ transform: (Self) -> T) -> some View where T : View {
		if condition {
			transform(self)
		} else {
			self
		}
	}

	@ViewBuilder func iflet<T, V>(_ optional: V?, _ transform: (Self, V) -> T) -> some View where T : View {
		if let v = optional {
			transform(self, v)
		} else {
			self
		}
	}
}


#endif
#endif
