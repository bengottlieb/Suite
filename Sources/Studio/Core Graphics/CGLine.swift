//
//  CGLine.swift
//  
//
//  Created by Ben Gottlieb on 5/1/23.
//

import Foundation
import SwiftUI

public struct CGLine: Codable, Equatable, Hashable, RawRepresentable {
	public var start: CGPoint
	public var end: CGPoint
	
	public static func ==(lhs: Self, rhs: Self) -> Bool {
		(lhs.start ≈≈ rhs.start && lhs.end ≈≈ rhs.end) || (lhs.start ≈≈ rhs.end && lhs.end ≈≈ rhs.start)
	}
	
	public init(start: CGPoint, end: CGPoint) {
		self.start = start
		self.end = end
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(start)
		hasher.combine(end)
	}
	
	public func rounded() -> CGLine {
		CGLine(start.rounded(), end.rounded())
	}
	
	public init(_ start: CGPoint, _ end: CGPoint) {
		self.start = start
		self.end = end
	}
	
	public var lowestPoint: CGPoint {
		start.y >= end.y ? start : end
	}
	
	public var highestPoint: CGPoint {
		start.y <= end.y ? start : end
	}
	
	public var normalTransform: CGAffineTransform {
		CGAffineTransformMakeTranslation(-midpoint.x, -midpoint.y).concatenating(.init(rotationAngle: -angle.radians))
	}
	
	public func transformed(by transform: CGAffineTransform) -> CGLine {
		CGLine(start.applying(transform), end.applying(transform))
	}
	
	public init(start: CGPoint, length: Double, angle: Angle) {
		self.start = start
		var degrees = angle.degrees
		while degrees < 0 { degrees += 360 }
		while degrees > 360 { degrees -= 360 }
		
		if degrees == 90 || degrees == 270 {
			self.end = self.start.offset(y: (degrees == 270 ? -1 : 1) * length)
		} else if degrees == 0 || degrees == 180 {
			self.end = self.start.offset(x: (degrees == 180 ? -1 : 1) * length)
		} else {
			self.end = CGPoint(x: start.x + cos(angle.radians) * length, y: start.y + sin(angle.radians) * length)
		}
	}
	
	public var origin: CGPoint { start }
	public var vector: CGPoint { CGPoint((end.x - start.x), (end.y - start.y)) }
	public var slope: Double { vector.y / vector.x }
	public var length: CGFloat { start.distance(to: end) }
	
	public func offset(x: Double = 0, y: Double = 0) -> CGLine {
		CGLine(start: start.offset(x: x, y: y), end: end.offset(x: x, y: y))
	}
	
	public var deltaX: Double { (end.x - start.x) }
	public var deltaY: Double { (end.y - start.y) }
	public var isHorizontal: Bool { start.y == end.y }
	public var isVertical: Bool { start.x == end.x }
	
	public var quadrant: Int {
		if (end.x - start.x) > 0 {
			return (end.y - start.y) > 0 ? 2 : 1
		} else {
			return (end.y - start.y) > 0 ? 4 : 3
		}
	}

	public func contains(_ point: CGPoint, tolerance: CGFloat? = nil) -> Bool {
		if let tolerance {
			return point.distance(to: self) < tolerance
		}

		let eps = CGFloat.ulpOfOne.squareRoot()
		return point.distance(to: start) + point.distance(to: end) <= length + eps
	}
	
	public var angle: Angle {
		if vector.x == 0 { return start.y > end.y ? .degrees(270) : .degrees(90) }
		if vector.y == 0 { return start.x > end.x ? .degrees(180) : .degrees(0) }
		
		let basis = Angle.radians(atan(vector.y / vector.x))
		switch quadrant {
		case 1: return .degrees(360) - .radians(basis.radians * -1)
		case 2: return basis
		case 3: return .degrees(180) + basis
		case 4: return .degrees(180) + basis
		default: return basis
		}
	}
	public var midpoint: CGPoint {
		get { (start + end) / 2.0 }
		set {
			let startDelta = midpoint - start
			let endDelta = midpoint - end
			
			start = newValue + startDelta
			end = newValue + endDelta
		}
	}
	mutating public func flip() {
		let end = self.end
		self.end = start
		start = end
	}
	public var flipped: CGLine { .init(start: end, end: start) }
	public func isParallel(to line: CGLine) -> Bool {
		let myAngle = angle.degrees
		let theirAngle = line.angle.degrees
		
		if myAngle == theirAngle { return true }
		if (myAngle + 180) == theirAngle { return true }
		if (theirAngle + 180) == myAngle { return true }
		return false
	}
	
	public func angle(with line: CGLine) -> Angle {
		let delta = self.angle - line.angle
	//	if delta.degrees < 0 { return delta + .degrees(360) }
		if delta.degrees > 180 { return delta - .degrees(180) }
		return delta
	}

	public func intersection(with line: CGLine) -> CGPoint? {
		if line.start == self.end { return self.end }
		if line.end == self.start { return self.start }
		if line.end == self.end { return self.end }
		if line.start == self.start { return self.start }
		
		guard let intersect = linesCross(start1: line.start, end1: line.end, start2: start, end2: end) else { return nil }
		
		return CGPoint(intersect.x, intersect.y)
	}
	
	public func segment(startingAt start: CGPoint, ofLength length: Double) -> CGLine? {
		if !contains(start) { return nil }
		
		let angle = self.angle
		let endX = start.x + length * cos(angle.radians)
		let endY = start.y + length * sin(angle.radians)
		
		return CGLine(start, CGPoint(endX, endY))
	}
}

extension CGLine: StringInitializable {
	public var rawValue: String {
		stringValue
	}
	
	public var stringValue: String {
		"(\(start),\(end))"
	}
	
	public init?(rawValue: String) {
		let components = rawValue.trimmingCharacters(in: .decimalDigits.inverted).components(separatedBy: "),(")
		if components.count != 2 { return nil }
		
		guard let start = CGPoint(rawValue: components[0].trimmingCharacters(in: .whitespacesAndNewlines)), let end = CGPoint(rawValue: components[1].trimmingCharacters(in: .whitespacesAndNewlines)) else { return nil }
		self.init(start: start, end: end)
	}
}

extension CGLine: CustomStringConvertible {
	public var description: String {
		"\(start.description) -> \(end.description) [\(midpoint.description)]"
	}
}

extension CGLine: CustomDebugStringConvertible {
	public var debugDescription: String {
		"\(start.description) -> \(end.description) [\(midpoint.description)]"
	}
}

func linesCross(start1: CGPoint, end1: CGPoint, start2: CGPoint, end2: CGPoint) -> (x: CGFloat, y: CGFloat)? {
	 // calculate the differences between the start and end X/Y positions for each of our points
	 let delta1x = end1.x - start1.x
	 let delta1y = end1.y - start1.y
	 let delta2x = end2.x - start2.x
	 let delta2y = end2.y - start2.y

	 // create a 2D matrix from our vectors and calculate the determinant
	 let determinant = delta1x * delta2y - delta2x * delta1y

	 if abs(determinant) < 0.0001 {
		  // if the determinant is effectively zero then the lines are parallel/colinear
		  return nil
	 }

	 // if the coefficients both lie between 0 and 1 then we have an intersection
	 let ab = ((start1.y - start2.y) * delta2x - (start1.x - start2.x) * delta2y) / determinant

	 if ab > 0 && ab < 1 {
		  let cd = ((start1.y - start2.y) * delta1x - (start1.x - start2.x) * delta1y) / determinant

		  if cd > 0 && cd < 1 {
				// lines cross – figure out exactly where and return it
				let intersectX = start1.x + ab * delta1x
				let intersectY = start1.y + ab * delta1y
				return (intersectX, intersectY)
		  }
	 }

	 // lines don't cross
	 return nil
}
