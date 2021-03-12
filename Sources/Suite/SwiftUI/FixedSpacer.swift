//
//  FixedSpacer.swift
//  
//
//  Created by Ben Gottlieb on 3/10/21.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public struct FixedSpacer: View {
    let width: CGFloat?
    let height: CGFloat?
    
    public init(width: CGFloat) {
        self.width = width
        self.height = nil
    }

    public init(height: CGFloat) {
        self.width = nil
        self.height = height
    }

    public var body: some View {
        Color.clear
            .frame(width: width ?? 0, height: height ?? 0)
    }
}
#endif
