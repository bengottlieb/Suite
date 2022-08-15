//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 8/15/22.
//

import SwiftUI

public extension View {
	func standardButton() -> some View {
		self
			.frame(minWidth: 44, minHeight: 44)
			.contentShape(Rectangle())
	}
}
