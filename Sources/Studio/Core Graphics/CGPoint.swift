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
	
	func centeredRect(size: CGSize) -> CGRect {
		return CGRect(x: self.x - size.width / 2, y: self.y - size.height / 2, width: size.width, height: size.height)
	}
	
	func square(side: CGFloat) -> CGRect { return self.centeredRect(size: CGSize(width: side, height: side)) }
	
	func adjustX(_ deltaX: CGFloat) -> CGPoint {  return CGPoint(x: self.x + deltaX, y: self.y) }
	func adjustY(_ deltaY: CGFloat) -> CGPoint {  return CGPoint(x: self.x, y: self.y + deltaY) }
	
	func round() -> CGPoint { return CGPoint(x: roundcgf(value: self.x), y: roundcgf(value: self.y) )}
	
	func distance(to other: CGPoint) -> CGFloat {
		hypot(self.x - other.x, self.y - other.y)
	}
	
	func nearestPoint(on line: CGLine) -> CGPoint {
		let A = x - line.start.x
		let B = y - line.start.y
		let C = (line.vector.x)
		let D = (line.vector.y)
		let sqLen = C * C + D * D
		let dot = A * C + B * D
		let distanceFactor = sqLen == 0 ? -1 : dot / sqLen
		if distanceFactor < 0 {
			return line.start
		} else if distanceFactor > 1 {
			return line.end
		}
		return CGPoint(line.start.x + distanceFactor * line.vector.x, line.start.y + distanceFactor * line.vector.y)
	}
	
	func distance(to line: CGLine) -> CGFloat {
		return nearestPoint(on: line).distance(to: self)
	}
	
	func offset(x: Double = 0, y: Double = 0) -> CGPoint {
		CGPoint(x: self.x + x, y: self.y + y)
	}
	
	static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}
	
	static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}
	
	static func /(lhs: CGPoint, rhs: Double) -> CGPoint {
		return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
	}
	
	static func *(lhs: CGPoint, rhs: Double) -> CGPoint {
		return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
	}

	init(_ x: CGFloat, _ y: CGFloat) {
		self.init(x: x, y: y)
	}
	
	static var randomUnitPoint: CGPoint {
		CGPoint(x: CGFloat.random(in: 0...1), y: CGFloat.random(in: 0...1))
	}
	
	var shortDescription: String {
		"(\(x.shortDescription), \(y.shortDescription))"
	}
	
	func close(to point: CGPoint, tolerance: CGFloat) -> Bool {
		let delta = point - self
		
		return abs(delta.x) <= tolerance && abs(delta.y) <= tolerance
	}
}

extension CGPoint: StringInitializable, RawRepresentable {
	public var rawValue: String {
		stringValue
	}
	
	public var stringValue: String {
		"(\(x),\(y))"
	}
	
	public init?(rawValue: String) {
		let components = rawValue.trimmingCharacters(in: .decimalDigits.inverted).components(separatedBy: ",")
		if components.count != 2 { return nil }
		
		guard let x = Double(components[0].trimmingCharacters(in: .whitespacesAndNewlines)), let y = Double(components[1].trimmingCharacters(in: .whitespacesAndNewlines)) else { return nil }
		self.init(x, y)
	}
}

extension CGPoint: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(x)
		hasher.combine(y)
	}
}

extension CGPoint: CustomStringConvertible {
	public var description: String { "(\(x.string(decimalPlaces: 1, padded: false)), \(y.string(decimalPlaces: 1, padded: false)))"}
}


extension CGPoint {
	public var debugDescription: String { "(\(x.string(decimalPlaces: 1, padded: false)), \(y.string(decimalPlaces: 1, padded: false)))"}
}
