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
	func frame(size: CGSize) -> some View {
		frame(width: size.width, height: size.height)
	}
	
	func frame(_ size: CGFloat) -> some View {
		frame(width: size, height: size)
	}
	
}

#if canImport(UIKit)
import UIKit

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension View {
	func resignFirstResponder() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}

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
#endif
