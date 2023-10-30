//
//  UnitRect.swift
//
//
//  Created by Ben Gottlieb on 10/29/23.
//

import SwiftUI

public struct UnitSize: Hashable, Sendable, Equatable, CustomStringConvertible {
	public var width: CGFloat
	public var height: CGFloat
	
	public init(width: CGFloat, height: CGFloat) {
		self.width = width
		self.height = height
	}
	
	public static var full = UnitSize(width: 1.0, height: 1.0)
	public static var zero = UnitSize(width: 0, height: 0)
	
	public var description: String { "\(width) x \(height)"}
}

public struct UnitRect: Hashable, Sendable, Equatable, CustomStringConvertible {
	public var origin: UnitPoint
	public var size: UnitSize
	
	public init(origin: UnitPoint = .zero, size: UnitSize) {
		self.origin = origin
		self.size = size
	}
	
	public static var full = UnitRect(origin: .zero, size: .full)
	public static var zero = UnitRect(origin: .zero, size: .zero)
	
	public var description: String { "(\(origin.x), \(origin.y)), (\(size))"}
}
