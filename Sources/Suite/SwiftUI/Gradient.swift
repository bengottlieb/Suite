//
//  Gradient.swift
//  
//
//  Created by Ben Gottlieb on 3/21/21.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public extension LinearGradient {
    init(_ colors: [Color], from: UnitPoint, to: UnitPoint) {
        self.init(gradient: Gradient(colors: colors), startPoint: from, endPoint: to)
    }
}
#endif
