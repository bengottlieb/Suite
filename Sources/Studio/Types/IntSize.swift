//
//  IntSize.swift
//  
//
//  Created by Ben Gottlieb on 2/14/22.
//

import CoreGraphics

public struct IntSize: Codable, Equatable, CustomStringConvertible {
	public var width: Int
	public var height: Int
	
	public init(_ w: Int, _ h: Int) { width = w; height = h }
	init(screenW w: Int, _ h: Int) { self.init(min(w, h), max(w, h)) }
	
	public var area: Int { width * height }
	public var description: String { "(\(width) x \(height))" }

	public static let zero = IntSize(0, 0)
}

public struct IntPoint: Codable, Equatable, CustomStringConvertible {
	public var x: Int
	public var y: Int
	
	public init(_ x: Int, _ y: Int) { self.x = x; self.y = y }
	public static let zero = IntPoint(0, 0)
	public var description: String { "(\(x), \(y))" }
}

extension IntSize {
	public static func ==(lhs: IntSize, rhs: CGSize) -> Bool {
		lhs.width == Int(rhs.width) && lhs.height == Int(rhs.height)
	}
}

extension IntPoint {
	public static func ==(lhs: IntPoint, rhs: CGPoint) -> Bool {
		lhs.x == Int(rhs.x) && lhs.y == Int(rhs.y)
	}
}

