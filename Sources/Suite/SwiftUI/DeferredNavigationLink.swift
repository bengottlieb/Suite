//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 9/29/20.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, *)
public struct DeferredNavigationLink<Destination: View, Content: View>: View {
	var destination: () -> Destination
	var content: () -> Content
	
	public init(destination: @escaping () -> Destination, content: @escaping () -> Content) {
		self.destination = destination
		self.content = content
	}
	
	public var body: some View {
		NavigationLink(destination: WrappedDestination(destination)) { content() }
	}
	
	struct WrappedDestination: View {
		var destination: () -> Destination
		
		init(_ destination: @escaping () -> Destination) {
			self.destination = destination
		}
		
		var body: some View {
			destination()
		}
	}
}

#endif
