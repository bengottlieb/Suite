//
//  ErrorDisplayingView.swift
//  
//
//  Created by Ben Gottlieb on 8/18/23.
//

import Foundation

@available(OSX 12, iOS 14.0, tvOS 13, watchOS 7, *)
public struct ErrorDisplayingView: View {
	let error: Error
	
	public init(error: Error) {
		self.error = error
	}
	
	public var body: some View {
		Text(error.localizedDescription)
	}
}
