//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 3/20/21.
//

import Foundation
import CoreGraphics

#if os(iOS)
    import UIKit
#endif

public extension CGPoint {
    var size: CGSize { CGSize(width: x, height: y )}
	 var description: String { "(\(x.string(decimalPlaces: 2, padded: false)), \(y.string(decimalPlaces: 2, padded: false)))"}
	 var debugDescription: String { "(\(x.string(decimalPlaces: 2, padded: false)), \(y.string(decimalPlaces: 2, padded: false)))"}

    func centeredRect(size: CGSize) -> CGRect {
        return CGRect(x: self.x - size.width / 2, y: self.y - size.height / 2, width: size.width, height: size.height)
    }
    
    func square(side: CGFloat) -> CGRect { return self.centeredRect(size: CGSize(width: side, height: side)) }
    
    func adjustX(_ deltaX: CGFloat) -> CGPoint {  return CGPoint(x: self.x + deltaX, y: self.y) }
    func adjustY(_ deltaY: CGFloat) -> CGPoint {  return CGPoint(x: self.x, y: self.y + deltaY) }
    
    func round() -> CGPoint { return CGPoint(x: roundcgf(value: self.x), y: roundcgf(value: self.y) )}

    func distance(to other: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - other.x, 2) + pow(self.y - other.y, 2))
    }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
         return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
         return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }
	
	static var randomUnitPoint: CGPoint {
		CGPoint(x: CGFloat.random(in: 0...1), y: CGFloat.random(in: 0...1))
	}
}

