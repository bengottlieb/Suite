//
//  NavigationView.swift
//  
//
//  Created by Ben Gottlieb on 12/25/20.
//

#if canImport(SwiftUI)
#if canImport(Combine)

import SwiftUI
import Combine

@available(OSX 11, iOS 13.0, watchOS 6.0, *)
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

@available(OSX 11, iOS 14.0, watchOS 7.0, *)
public extension View {
    func navigationLink<Content: Equatable, Destination: View>(boundTo: Binding<Content?>, destination: @escaping (Content) -> Destination) -> some View {
        ContainedContentNavigationLink(root: self, binding: boundTo, destination: destination)
    }

    func navigationLink<Destination: View>(boundTo: Binding<Bool>, destination: @escaping () -> Destination) -> some View {
        ContainedOptionalNavigationLink(root: self, binding: boundTo, destination: destination)
    }
}

@available(OSX 11, iOS 14.0, watchOS 7.0, *)
struct ContainedOptionalNavigationLink<Root: View, Destination: View>: View {
    let root: Root
    @Binding var binding: Bool
    let destination: () -> Destination
    
    var body: some View {
        ZStack() {
            root
            NavigationLink(
                destination: destination(),
                isActive: $binding,
                label: {
                    EmptyView()
                })
        }
    }
}

@available(OSX 11, iOS 14.0, watchOS 7.0, *)
struct ContainedContentNavigationLink<Root: View, Content: Equatable, Destination: View>: View {
    let root: Root
    @State var isLinkActive = false
    @Binding var binding: Content?
    let destination: (Content) -> Destination
    
    var body: some View {
        ZStack() {
            root
            if let contents = binding {
                NavigationLink(
                    destination: destination(contents),
                    isActive: $isLinkActive,
                    label: {
                        EmptyView()
                    })
            }
        }
        .onChange(of: binding) { value in
            isLinkActive = binding != nil
        }
    }
}

#endif
#endif
