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
	
	public var description: String { "\(width.pretty()) x \(height.pretty())"}
}

public struct UnitRect: Hashable, Sendable, Equatable, CustomStringConvertible {
	public var origin: UnitPoint
	public var size: UnitSize
	
	public var x: CGFloat { origin.x }
	public var y: CGFloat { origin.y }
	public var width: CGFloat { size.width }
	public var height: CGFloat { size.height }
	public var right: CGFloat { min(1.0, x + width) }
	public var bottom: CGFloat { min(1.0, y + height) }
	public var midX: CGFloat { size.width / 2 + origin.x }
	public var midY: CGFloat { size.height / 2 + origin.y }
	public var midPoint: UnitPoint { .init(x: midX, y: midY) }

	public init(origin: UnitPoint = .zero, size: UnitSize) {
		self.origin = origin
		self.size = size
	}
	
	public init(origin: UnitPoint = .zero, bottomRight: UnitPoint = .bottomLeading) {
		self.origin = origin
		self.size = .init(width: bottomRight.x - origin.x, height: bottomRight.y - origin.y)
	}
	
	public func contains(_ other: UnitRect) -> Bool {
		x <= other.x && y <= other.y && bottom >= other.bottom && right >= other.right
	}
	
	public func overlap(with other: UnitRect) -> UnitRect? {
		if right < other.x || x > other.right || bottom < other.y || y > other.bottom { return nil }
		
		let origin = UnitPoint(x: max(x, other.x), y: max(y, other.y))
		let bottomRight = UnitPoint(x: min(right, other.right), y: max(bottom, other.bottom))
		
		return UnitRect(origin: origin, bottomRight: bottomRight)
	}
	
	public static var full = UnitRect(origin: .zero, size: .full)
	public static var zero = UnitRect(origin: .zero, size: .zero)
	
	public var description: String { "(\(origin.x.pretty()), \(origin.y.pretty())), (\(size))"}
	public func union(with rect: UnitRect) -> UnitRect {
		.init(origin: .init(x: min(rect.x, x), y: min(rect.y, y)), bottomRight: .init(x: max(rect.right, right), y: max(rect.bottom, bottom)))
	}
}

fileprivate extension CGFloat {
	var short: String {
		String(format: "%.02f", self)
	}
}
