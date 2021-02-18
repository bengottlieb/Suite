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

extension CGRect {
	#if os(iOS)
		public typealias Placement = UIView.ContentMode
	#else
		public enum Placement { case scaleToFill, scaleAspectFit, scaleAspectFill, none, center, top, bottom, left, right, topLeft, topRight, bottomLeft, bottomRight }
	#endif
}


public func roundcgf(value: CGFloat) -> CGFloat { return CGFloat(floorf(Float(value))) }

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
		return sqrt(pow(self.x - other.x, 2) + pow(self.y - other.y, 2))
	}

	static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		 return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}

	static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		 return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}

}

public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public extension CGSize {
	var dimString: String { "\(Int(width)) x \(Int(height))" }

	var largestDimension: CGFloat { max(width, height) }
	var smallestDimension: CGFloat { min(width, height) }

	enum AspectRatioType: Int { case portrait, landscape, square }
	func scaled(within limit: CGSize) -> CGSize {
		let myAspectRatio = self.width / self.height
		let theirAspectRatio = limit.width / limit.height
		var computed = limit
		
		if myAspectRatio < theirAspectRatio {
			computed.width = limit.height * myAspectRatio
		} else {
			computed.height = limit.width / myAspectRatio
		}
		return computed
	}
	
	var isSquare: Bool { return self.width > 0 && self.width == self.height }
	var rect: CGRect { return CGRect(x: 0, y: 0, width: self.width, height: self.height) }

	func round() -> CGSize { return CGSize(width: roundcgf(value: self.width), height: roundcgf(value: self.height) )}

	var aspectRatio: CGFloat { return self.width / self.height }
	var aspectRatioType: AspectRatioType {
		switch self.aspectRatio {
		case ..<1: return .portrait
		case 1: return .square
		default: return .landscape
		}
	}
	
	var point: CGPoint { CGPoint(x: width, y: height )}
	
	func scaled(by factor: CGFloat) -> CGSize {
		return CGSize(width: self.width * factor, height: self.height * factor)
	}
	
	func scaleDown(toWidth maxWidth: CGFloat?, height maxHeight: CGFloat?) -> CGSize {
		var heightGood = false, widthGood = false
		
		if let maxH = maxHeight, maxH < self.height {
			heightGood = true
		}

		if let maxW = maxWidth, maxW < self.width {
			heightGood = true
		}
		
		if heightGood && widthGood { return self }
		
		let aspect = self.aspectRatio
		
		if heightGood && maxWidth != nil {
			return CGSize(width: maxWidth!, height: maxWidth! / aspect)
		}
		
		if widthGood && maxHeight != nil {
			return CGSize(width: maxHeight! * aspect, height: maxHeight!)
		}
		
		if let maxHeight = maxHeight, let maxWidth = maxWidth {
			let calcWidth = min(maxWidth, maxHeight * aspect)
			let calcHeight = min(maxHeight, maxWidth / aspect)
			
			if (calcHeight / maxHeight) > (calcWidth / maxWidth) {		//height is better match
				return CGSize(width: calcHeight * aspect, height: calcHeight)
			} else {
				return CGSize(width: calcWidth, height: calcWidth / aspect)
			}
		}
		return CGSize(width: maxWidth ?? self.width, height: maxHeight ?? self.height)
	}
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
