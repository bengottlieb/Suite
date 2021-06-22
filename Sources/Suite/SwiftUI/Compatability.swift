//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 6/21/21.
//

#if canImport(Combine)
import SwiftUI
#endif

#if os(OSX)
@available(macOS 10.15, *)
public extension View {
    func navigationBarItems(leading: Any? = nil, trailing: Any? = nil) -> some View { self }
    func navigationBarHidden(_ hidden: Bool) -> some View { self }
}
#endif
