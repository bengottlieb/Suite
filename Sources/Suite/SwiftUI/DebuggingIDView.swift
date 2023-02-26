//
//  DebuggingIDView.swift
//  
//
//  Created by Ben Gottlieb on 2/15/23.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, watchOS 8.0, *)
public extension View {
	@ViewBuilder func showDebuggingID(visible: Bool? = nil, _ id: String, alignment: Alignment = .topLeading) -> some View {
		if visible ?? DebuggingIDView.showViewDebuggingIDs {
			self
				.overlay(alignment: alignment) {
					DebuggingIDView(id: id)
				}
		} else {
			self
		}
	}
}

public struct DebuggingIDView: View {
	public static var showViewDebuggingIDs = false
	
	let id: String
	public var body: some View {
		Text(id)
			.foregroundColor(.white)
			.font(.caption)
			.truncationMode(.middle)
			.padding(3)
			.backgroundColor(.red)
			.shadow(radius: 3)
	}
}

