//
//  BoundNavigationLink.swift
//  
//
//  Created by Ben Gottlieb on 11/16/21.
//

import SwiftUI

public struct BoundNavigationLink<Bound, DestinationView: View>: View {
	@Binding var bound: Bound?
	@ViewBuilder var destination: (Bound) -> DestinationView
	
	public init(boundTo: Binding<Bound?>, @ViewBuilder destination: @escaping (Bound) -> DestinationView) {
		_bound = boundTo
		self.destination = destination
	}
	
	public var body: some View {
		NavigationLink(isActive: Binding(get: { bound != nil }, set: { _ in }), destination: { Wrapped(parentBound: bound, destination: destination) }) { EmptyView() }
	}
	
	struct Wrapped: View {
		var parentBound: Bound?
		@ViewBuilder var destination: (Bound) -> DestinationView

		var body: some View {
			if let bound = parentBound {
				destination(bound)
			}
		}
	}
}
