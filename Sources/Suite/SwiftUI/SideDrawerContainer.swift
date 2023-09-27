//
//  SideDrawerContainer.swift
//  
//
//  Created by Ben Gottlieb on 7/21/23.
//

import SwiftUI

@available(OSX 12, iOS 14.0, tvOS 13, watchOS 8, *)
public struct SideDrawerContainer<Content: View>: View {
	@Binding var isShown: Bool
	let side: Side
	let content: (Binding<Bool>) -> Content

	public enum Side { case leading, trailing }
	
	public init(isShown: Binding<Bool>, side: Side = .leading, content: @escaping (Binding<Bool>) -> Content) {
		self.content = content
		self.side = side
		_isShown = isShown
	}
	
	public var body: some View {
		GeometryReader { geo in
			ZStack {
				Color.black.opacity(isShown ? 0.5 : 0.0)
					.ignoresSafeArea()
					.onTapGesture {
						if isShown { withAnimation { isShown = false }}
					}
				
				HStack {
					content($isShown)
					Spacer()
				}
				.offset(x: isShown ? 0 : (side == .leading ? -geo.width : geo.width))
			}
		}
	}
}
