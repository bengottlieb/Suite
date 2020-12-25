//
//  NavigationView.swift
//  
//
//  Created by Ben Gottlieb on 12/25/20.
//

#if canImport(SwiftUI)

import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public struct OptionalNavigationLink<Check, Content: View, Dest: View>: View {
	@Binding var check: Check?
	var destination: (Check) -> Dest
	var label: () -> Content
	
	public init(check: Binding<Check?>, destination: @escaping (Check) -> Dest, label: @escaping () -> Content) {
		_check = check
		self.destination = destination
		self.label = label
	}
	
	public var body: some View {
		NavigationLink(destination: Deferred(destination(check!)), isActive: $check.bool, label: label)
	}
}



#endif
