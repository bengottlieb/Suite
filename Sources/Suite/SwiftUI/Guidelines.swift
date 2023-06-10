//
//  Guidelines.swift
//  
//
//  Created by Ben Gottlieb on 3/16/21.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public struct GuideLinesShape: Shape {
	let guide: GuideLines
	
	public init(_ guidelines: GuideLines) {
		guide = guidelines
	}
	
	public func path(in rect: CGRect) -> Path {
		guide.with(rect).gridLines
	}
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public extension View {
	func guideLines(_ guide: GuideLines, color: Color? = nil) -> some View {
		let stroke = color ?? .gray
		return self
			.overlay(GuideLinesShape(guide).stroke(stroke, lineWidth: 0.5))
	}
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public struct GuideLines: Sendable {
	var xMarks: [CGFloat] = []
	var yMarks: [CGFloat] = []
	var size: CGSize?
	
	public init(xMarks: [CGFloat] = [], yMarks: [CGFloat] = [], size: CGSize? = nil) {
		self.xMarks = xMarks
		self.yMarks = yMarks
		self.size = size
	}
	
	public init(x: Int, y: Int, size: CGSize? = nil) {
		let xWidth = 1 / CGFloat(x)
		let yWidth = 1 / CGFloat(y)
		xMarks = (0...x).map { CGFloat($0) * xWidth }
		yMarks = (0...x).map { CGFloat($0) * yWidth }
		self.size = size
	}
	
	public func with(_ proxy: GeometryProxy) -> GuideLines {
		var newLines = self
		newLines.size = proxy.size
		return newLines
	}
	
	public func with(_ rect: CGRect) -> GuideLines {
		var newLines = self
		newLines.size = rect.size
		return newLines
	}
	
	var gridLines: Path {
		var path = Path()

		guard let size = size else { return path }
		for idx in xMarks.indices {
			let x = self[idx, 0].x
			
			path.move(to: CGPoint(x: x, y: 0))
			path.addLine(to: CGPoint(x: x, y: size.height))
		}

		for idx in yMarks.indices {
			let y = self[0, idx].y
			
			path.move(to: CGPoint(x: 0, y: y))
			path.addLine(to: CGPoint(x: size.width, y: y))
		}

		return path
	}
	
	@discardableResult mutating
	public func addXMark(_ mark: CGFloat) -> Self { xMarks.append(mark); return self }
	
	@discardableResult mutating
	public func addYMark(_ mark: CGFloat) -> Self { yMarks.append(mark); return self }
	
	public var numberOfXMarks: Int { xMarks.count }
	public var numberOfYMarks: Int { yMarks.count }
	
	public subscript(x: Int, y: Int) -> CGPoint {
		point(x: x, y: y)
	}
	
	func point(x: Int, y: Int) -> CGPoint {
		guard let size = size, x < xMarks.count, y < yMarks.count else { return .zero }
		let xMax = max(xMarks.max() ?? 0, 1.0)
		let yMax = max(yMarks.max() ?? 0, 1.0)
		
		return CGPoint(x: size.width * xMarks[x] / xMax, y: size.height * yMarks[y] / yMax)
	}
}
#endif
