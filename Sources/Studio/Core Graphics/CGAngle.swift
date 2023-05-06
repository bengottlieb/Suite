//
//  CGAngle.swift
//  Voronoi
//
//  Created by Ben Gottlieb on 5/1/23.
//

import Foundation
import SwiftUI

public struct CGAngle: Codable, Equatable, Hashable {
	public let a: CGPoint
	public let b: CGPoint
	public let c: CGPoint
	
	public init(a: CGPoint, b: CGPoint, c: CGPoint) {
		self.a = a
		self.b = b
		self.c = c
	}
	
	public var angle: Angle {
		let ab = CGLine(start: a, end: b).length
		let bc = CGLine(start: b, end: c).length
		let ac = CGLine(start: a, end: c).length
		
		let angle = acos((pow(ab, 2) + pow(bc, 2) - pow(ac, 2)) / (2 * ab * bc))
		return .radians(angle)
	}
}
