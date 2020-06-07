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
public extension View {
	func resignFirstResponder() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
#endif


#endif
#endif
