//
//  CoreGraphics.swift
//  
//
//  Created by Ben Gottlieb on 12/2/19.
//

import Foundation
import CoreGraphics

#if os(iOS)
	import UIKit
#endif

public func roundcgf(value: CGFloat) -> CGFloat { return CGFloat(floorf(Float(value))) }

public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}


extension CGRect {
	#if os(iOS)
		public typealias Placement = UIView.ContentMode
	#else
        public enum Placement: Int { case scaleToFill, scaleAspectFit, scaleAspectFill, none, center, top, bottom, left, right, topLeft, topRight, bottomLeft, bottomRight }
	#endif
}

extension CGRect.Placement: Codable {
    public enum PlacementError: Error { case invalidIntegerValue, invalidStringValue, noValue }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            if let value = CGRect.Placement(rawValue: int) {
                self = value
            } else {
                throw PlacementError.invalidIntegerValue
            }
        } else if let string = try? container.decode(String.self) {
            switch string {
            case "center": self = .center
            case "top": self = .top
            case "bottom": self = .bottom
            case "left": self = .left
            case "right": self = .right
            case "topLeft": self = .topLeft
            case "topRight": self = .topRight
            case "bottomLeft": self = .bottomLeft
            case "bottomRight": self = .bottomRight
            default: throw PlacementError.invalidStringValue
            }
        } else {
            throw PlacementError.noValue
        }

    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(rawValue)
    }
    
    
}

public extension CGRect.Placement {
	var isLeft: Bool { self == .left || self == .topLeft || self == .bottomLeft }
	var isCenterH: Bool { self == .top || self == .center || self == .bottom }
	var isRight: Bool { self == .right || self == .topRight || self == .bottomRight }

	var isTop: Bool { self == .top || self == .topLeft || self == .topRight }
	var isCenterV: Bool { self == .left || self == .center || self == .right }
	var isBottom: Bool { self == .bottomLeft || self == .bottom || self == .bottomRight }
}


public extension CGRect {
	var largestDimension: CGFloat { max(width, height) }
	var smallestDimension: CGFloat { min(width, height) }

	func scaled(to factor: CGFloat) -> CGRect {
		return CGRect(x: self.x * factor, y: self.y * factor, width: self.width * factor, height: self.height * factor)
	}

	init(x: CGFloat = 0, y: CGFloat = 0, size: CGSize) {
		self.init(x: x, y: y, width: size.width, height: size.height)
	}
	
	init(origin: CGPoint, width: CGFloat, height: CGFloat) {
		self.init(x: origin.x, y: origin.y, width: width, height: height)
	}
	
//	#if os(iOS)
//		func inset(by insets: UIEdgeInsets) -> CGRect {
//			return CGRect(x: self.origin.x + insets.left, y: self.origin.y + insets.top, width: self.width - (insets.left + insets.right), height: self.height - (insets.top + insets.bottom))
//		}
//	#endif
	
	var aspectRatio: CGFloat { return self.size.aspectRatio }
	var aspectRatioType: CGSize.AspectRatioType { return self.size.aspectRatioType }
	
	var x: CGFloat {
		set { self.origin.x = newValue }
		get { return self.origin.x }
	}
	
	var y: CGFloat {
		set { self.origin.y = newValue }
		get { return self.origin.y }
	}
	
	var center: CGPoint { return CGPoint(x: self.midX, y: self.midY) }
	func round() -> CGRect { return CGRect(x: roundcgf(value: self.origin.x), y: roundcgf(value: self.origin.y), width: roundcgf(value: self.width + (self.origin.x - roundcgf(value: self.origin.x))), height: roundcgf(value: self.height + (self.origin.y - roundcgf(value: self.origin.y)))) }
	
	func scaledRectWithAspectRatio(ratio: CGFloat) -> CGRect {
		var width = self.width, height = self.height
		
		if width / ratio < height {
			height = width / ratio
		} else {
			width = height * ratio
		}
		
		return CGRect(x: (self.width - width) / 2, y: (self.height - height) / 2, width: width, height: height)
	}
	
	func within(limit: CGRect, placed: CGRect.Placement) -> CGRect {
		let parent = limit
		let child = self
		var newSize = self.size
		var newRect = (child.width < parent.width && child.height < parent.height) ? child : child.size.scaled(within: parent.size).rect
		var delta: CGFloat = 0.0

		newRect.origin = parent.origin
		
		switch (placed) {
		case .scaleToFill: return parent
		case .scaleAspectFill:
			newRect = parent
			newSize = child.size.scaled(within: parent.size)
			if (newSize.height < parent.height) {			//image is too short to fit.
				delta = newSize.width * (parent.height / newSize.height) - newSize.width
				newSize.width = parent.width + delta
				newSize.height = parent.height
				newRect.origin.x = delta / 2
			} else if (newSize.width < parent.width) {
				delta = newSize.height * (parent.width / newSize.width) - newSize.height
				newSize.height = parent.height + delta
				newSize.width = parent.width
				newRect.origin.y -= delta / 2
			}
		case .scaleAspectFit:
			newRect = parent
			newSize = child.size.scaled(within: parent.size)
			if (newSize.height < parent.height) {			//image is too short to fit.
				delta = parent.height - newSize.height
				newRect.origin.y += delta / 2
				newRect.size.height = newSize.height
			} else if (newSize.width < parent.width) {
				delta = parent.width - newSize.width
				newRect.origin.x += delta / 2
				newRect.size.width = newSize.width
			}
			
		case .center:
			let insetX = (parent.width - newRect.width) / 2
			let insetY = (parent.height - newRect.height) / 2
			newRect.origin.x += insetX
			newRect.origin.y += insetY
			newRect.size.height = min(limit.height - insetY * 2, self.height)
			newRect.size.width = min(limit.width - insetX * 2, self.width)

		case .top:
			newRect.origin.x += (parent.width - newRect.width) / 2
			newRect.origin.y = parent.origin.y

		case .bottom:
			newRect.origin.x += (parent.width - newRect.width) / 2
			newRect.origin.y = (parent.height - newRect.height)

		case .left:
			newRect.origin.x = parent.origin.x
			newRect.origin.y += (parent.height - newRect.height) / 2

		case .right:
			newRect.origin.x += (parent.width - newRect.width)
			newRect.origin.y += (parent.height - newRect.height) / 2

		case .topLeft:
			newRect.origin.x = parent.origin.x
			newRect.origin.y = parent.origin.y

		case .bottomLeft:
			newRect.origin.x = parent.origin.x
			newRect.origin.y += (parent.height - newRect.height)

		case .topRight:
			newRect.origin.x += (parent.width - newRect.width)
			newRect.origin.y = parent.origin.y

		case .bottomRight:
			newRect.origin.x += (parent.width - newRect.width)
			newRect.origin.y += (parent.height - newRect.height)

		default: break
		}
		return newRect
	}

	var upperLeft: CGPoint { return CGPoint(x: self.minX, y: self.minY) }
	var upperRight: CGPoint { return CGPoint(x: self.maxX, y: self.minY) }
	var lowerLeft: CGPoint { return CGPoint(x: self.minX, y: self.maxY) }
	var lowerRight: CGPoint { return CGPoint(x: self.maxX, y: self.maxY) }
	
	func flippedVertically(in frame: CGRect) -> CGRect {
		return CGRect(x: self.origin.x, y: frame.height - (self.origin.y + self.height), size: self.size)
	}
	
	func leading(percentage: CGFloat) -> CGRect {
		precondition(percentage >= 0.0 && percentage <= 1.0)
		return CGRect(x: self.x, y: self.y, width: self.width * percentage, height: self.height)
	}
	
	func trailing(percentage: CGFloat) -> CGRect {
		precondition(percentage >= 0.0 && percentage <= 1.0)
		return CGRect(x: self.x + (self.width * (1.0 - percentage)), y: self.y, width: self.width * percentage, height: self.height)
	}
	
	func upper(percentage: CGFloat) -> CGRect {
		precondition(percentage >= 0.0 && percentage <= 1.0)
		return CGRect(x: self.x, y: self.y, width: self.width, height: self.height * percentage)
	}
	
	func lower(percentage: CGFloat) -> CGRect {
		precondition(percentage >= 0.0 && percentage <= 1.0)
		return CGRect(x: self.x, y: self.y + (self.height * (1.0 - percentage)), width: self.width, height: self.height * percentage)
	}

	func leading(amount: CGFloat) -> CGRect { return CGRect(x: self.x, y: self.y, width: amount, height: self.height) }
	func trailing(amount: CGFloat) -> CGRect { return CGRect(x: self.x + (self.width - amount), y: self.y, width: amount, height: self.height) }
	func upper(amount: CGFloat) -> CGRect { return CGRect(x: self.x, y: self.y, width: self.width, height: amount) }
	func lower(amount: CGFloat) -> CGRect { return CGRect(x: self.x, y: self.y + (self.height - amount), width: self.width, height: amount) }
	
	func offset(x: CGFloat = 0, y: CGFloat = 0) -> CGRect {
		return CGRect(x: self.origin.x + x, y: self.origin.y + y, width: self.width, height: self.height)
	}
	
	func centerVertically(height: CGFloat) -> CGRect {
		let delta = (self.height - height) / 2
		return CGRect(x: self.x, y: self.y + delta, width: self.width, height: height)
	}
}
