//
//  SimpleProgressView.swift
//  
//
//  Created by Ben Gottlieb on 9/29/23.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, watchOS 8.0, *)
public struct SimpleProgressView: View {
	var label: String?
	
	public init(label: String? = nil) {
		self.label = label
	}
	
	public var body: some View {
		VStack {
			Spacer()
			ProgressView()
			if let label {
				Text(label)
					.font(.callout)
					.opacity(0.66)
					.padding()
			}
			Spacer()
		}
	}
}
