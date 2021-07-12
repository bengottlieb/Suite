//
//  Point.swift
//  
//
//  Created by Ben Gottlieb on 7/11/21.
//

import Foundation

public struct Point: Equatable {
	public var x: Int
	public var y: Int
	
	public static func ==(lhs: Point, rhs: Point) -> Bool {
		lhs.x == rhs.x && lhs.y == rhs.y
	}
	
	public init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}
}
