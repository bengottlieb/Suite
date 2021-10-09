//
//  CGPath.swift
//  
//
//  Created by Ben Gottlieb on 10/9/21.
//

import CoreGraphics

public extension CGPath {
	var boundingSize: CGSize {
		let points = self.points
		if points.isEmpty { return .zero }
		let xs = points.map { $0.x }
		let ys = points.map { $0.y }
		return CGSize(width: xs.max()! - xs.min()!, height: ys.max()! - ys.min()!)
	}

	var points: [CGPoint] {
		var points: [CGPoint] = []
		
		self.applyWithBlock { element in
			
			switch element.pointee.type
			{
			case .moveToPoint, .addLineToPoint:
				points.append(element.pointee.points.pointee)
				
			case .addQuadCurveToPoint:
				points.append(element.pointee.points.pointee)
				points.append(element.pointee.points.advanced(by: 1).pointee)
				
			case .addCurveToPoint:
				points.append(element.pointee.points.pointee)
				points.append(element.pointee.points.advanced(by: 1).pointee)
				points.append(element.pointee.points.advanced(by: 2).pointee)
				
			default:
				break
			}
		}
		
		return points
	}
}
