//
//  Shape.swift
//  
//
//  Created by ben on 3/23/20.
//

#if canImport(Combine)

import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension Shape {
    func fill<S:ShapeStyle>(_ fillContent: S, andStroke stroke: Color) -> some View {
        ZStack {
            self.fill(fillContent)
            self.stroke(stroke)
        }
    }

}

#endif
