//
//  Deferred.swift
//  
//
//  Created by Ben Gottlieb on 12/21/20.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public struct Deferred<Content: View>: View {
	var builder: () -> Content
	@State var content: Content?
	let delay: TimeInterval?
	
	public init(delay: TimeInterval? = nil,  @ViewBuilder _ content: @escaping () -> Content) {
		self.delay = delay
		builder = content
	}
	
	public var body: some View {
		HStack() {
			if let content = content { content }
		}
		.onAppear {
			if let delay = delay {
				DispatchQueue.main.async(after: delay) {
					self.content = builder()
				}
			} else {
				self.content = builder()
			}
		}
	}
}

#endif
