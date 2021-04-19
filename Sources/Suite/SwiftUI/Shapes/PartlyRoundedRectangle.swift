//
//  PartlyRoundedRectangle.swift
//  
//
//  Created by Ben Gottlieb on 4/12/21.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct PartlyRoundedRectangle: Shape {
	public enum Corner { case topLeading, topTrailing, bottomLeading, bottomTrailing }
	
	let corners: [Corner]
	let radius: CGFloat
	
	public init(corners: [Corner], radius: CGFloat) {
		self.corners = corners
		self.radius = radius
	}

	public func path(in rect: CGRect) -> Path {
		var path = Path()
		let radius = min(self.radius, min(rect.width, rect.height))
		
		path.move(to: CGPoint(rect.minX, rect.midY))
		if corners.contains(.topLeading) {
			path.addLine(to: CGPoint(rect.minX, rect.minY + radius))
			path.addArc(center: CGPoint(rect.minX + radius, rect.minY + radius), radius: radius, startAngle: .nineOClock, endAngle: .twelveOClock, clockwise: false)
		} else {
			path.addLine(to: CGPoint(rect.minX, rect.minY))
		}
		path.addLine(to: CGPoint(rect.midX, rect.minY))

		if corners.contains(.topTrailing) {
			path.addLine(to: CGPoint(rect.maxX - radius, rect.minY))
			path.addArc(center: CGPoint(rect.maxX - radius, rect.minY + radius), radius: radius, startAngle: .twelveOClock, endAngle: .threeOClock, clockwise: false)
		} else {
			path.addLine(to: CGPoint(rect.maxX, rect.minY))
		}
		path.addLine(to: CGPoint(rect.maxX, rect.midY))

		if corners.contains(.bottomTrailing) {
			path.addLine(to: CGPoint(rect.maxX, rect.maxY - radius))
			path.addArc(center: CGPoint(rect.maxX - radius, rect.maxY - radius), radius: radius, startAngle: .threeOClock, endAngle: .sixOClock, clockwise: false)
		} else {
			path.addLine(to: CGPoint(rect.maxX, rect.maxY))
		}
		path.addLine(to: CGPoint(rect.midX, rect.maxY))

		if corners.contains(.bottomLeading) {
			path.addLine(to: CGPoint(rect.minX + radius, rect.maxY))
			path.addArc(center: CGPoint(rect.minX + radius, rect.maxY - radius), radius: radius, startAngle: .sixOClock, endAngle: .nineOClock, clockwise: false)
		} else {
			path.addLine(to: CGPoint(rect.minX, rect.maxY))
		}
		path.closeSubpath()
		return path
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension Angle {
	static var twelveOClock = Angle(degrees: 270)
	static var threeOClock = Angle(degrees: 0)
	static var sixOClock = Angle(degrees: 90)
	static var nineOClock = Angle(degrees: 180)
}


@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
struct PartlyRoundedRectangle_Previews: PreviewProvider {
	static var previews: some View {
		HStack(spacing: 20) {
			PartlyRoundedRectangle(corners: [.topLeading, .topTrailing], radius: 10)
				.fill(Color.green)

			PartlyRoundedRectangle(corners: [.topTrailing, .bottomTrailing], radius: 10)
				.fill(Color.orange)
		}
	}
}

#endif
