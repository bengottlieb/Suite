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
		if let bound = bound {
			NavigationLink(isActive: .constant(true), destination: { destination(bound) }) { EmptyView() }
		}
	}
}
