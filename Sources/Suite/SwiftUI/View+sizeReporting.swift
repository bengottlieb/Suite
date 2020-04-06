//
//  File.swift
//  
//
//  Created by ben on 4/5/20.
//

#if canImport(SwiftUI)
#if canImport(Combine)

import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct SizeViewModifier: ViewModifier {
    @Binding var size: CGSize
    
    public func body(content: Content) -> some View {
        GeometryReader { proxy in
            content
                .frame(size: proxy.size)
                .onAppear { self.size = proxy.size }
        }
        .clipped()
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension View {		// Tracks the size available for the view
    func sizeReporting(_ size: Binding<CGSize>) -> some View {
        self.modifier(SizeViewModifier(size: size))
    }
}

#endif
#endif
