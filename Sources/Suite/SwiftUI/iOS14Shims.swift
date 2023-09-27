//
//  iOS14Shims.swift
//
//
//  Created by Ben Gottlieb on 8/26/23.
//

import SwiftUI



@available(OSX 12, iOS 13.0, watchOS 6.0, *)
public extension View {
	@ViewBuilder func monospacedDigit14() -> some View {
		if #available(iOS 15.0, *) {
			monospacedDigit()
		} else {
			self
		}
	}
	
	@ViewBuilder func alignedOverlay<Content: View>(_ alignment: Alignment, content: @escaping () -> Content) -> some View {
		if #available(iOS 15.0, *) {
			overlay(alignment: alignment, content: content)
		} else {
			overlay(
				HStack {
					if alignment == .trailing || alignment == .topTrailing || alignment == .bottomTrailing { Spacer() }
					VStack {
						if alignment == .bottom || alignment == .bottomTrailing || alignment == .bottomLeading { Spacer() }

						content()
						
						if alignment == .top || alignment == .topTrailing || alignment == .topLeading { Spacer() }
					}
					if alignment == .leading || alignment == .topLeading || alignment == .bottomLeading { Spacer() }
				}
			)
		}
			
			
	}
}
