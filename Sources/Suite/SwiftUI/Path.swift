//
//  Path.swift
//  
//
//  Created by Ben Gottlieb on 3/20/21.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public extension Path {
    mutating func addCurve(to end: CGPoint, control1 cp1: CGPoint, control2 cp2: CGPoint, showingControlPoints: Bool) {
        if showingControlPoints, let current = currentPoint {
            move(to: cp1)
            encircle(radius: 5)
            move(to: cp1)
            addLine(to: current)

            move(to: cp2)
            encircle(radius: 5)
            move(to: cp2)
            addLine(to: end)

            move(to: current)
        }
        addCurve(to: end, control1: cp1, control2: cp2)
    }
    
    mutating func encircle(radius: CGFloat) {
        guard let current = currentPoint else { return }
        addEllipse(in: CGRect(x: current.x - radius / 2, y: current.y - radius / 2, width: radius, height: radius))
    }
}
#endif
