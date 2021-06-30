//
//  PlacedView.swift
//  
//
//  Created by Ben Gottlieb on 2/18/21.
//

#if canImport(Combine)
import SwiftUI
import Studio

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public struct PlacedView<Content: View>: View {
	let content: () -> Content
	let placement: CGRect.Placement
	
	public init(_ content: Content, _ placement: CGRect.Placement) {
		self.content = { content }
		self.placement = placement
	}
	
	public init(_ placement: CGRect.Placement, _ content: @escaping () -> Content) {
		self.content = content
		self.placement = placement
	}
	
	public var body: some View {
		VStack() {
			if !placement.isTop { Spacer() }
			
			HStack() {
				if !placement.isLeft { Spacer() }
				
				content()
				
				if !placement.isRight { Spacer() }
			}
			
			if !placement.isBottom { Spacer() }
		}
    }
}
#endif
