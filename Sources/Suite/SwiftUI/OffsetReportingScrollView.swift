//
//  OffsetReportingScrollView.swift
//  
//
//  Created by Ben Gottlieb on 2/13/23.
//

import SwiftUI

public struct OffsetReportingScrollView<Content: View>: View {
	var axes: Axis.Set = [.vertical]
	var showsIndicators = true
	@Binding var offset: CGPoint
	@ViewBuilder var content: () -> Content
	
	private let coordinateSpaceName = UUID()
	
	public init(_ axes: Axis.Set = [.vertical], showsIndicators: Bool = true, offset: Binding<CGPoint>, content: @escaping () -> Content) {
		self.axes = axes
		self.showsIndicators = showsIndicators
		self.content = content
		_offset = offset
	}
	
	public var body: some View {
		ScrollView(axes, showsIndicators: showsIndicators) {
			PositionReportingView(
				coordinateSpace: .named(coordinateSpaceName),
				position: Binding(
					get: { offset },
					set: { newOffset in
						offset = newOffset
					}
				),
				content: content
			)
		}
		.coordinateSpace(name: coordinateSpaceName)
	}
}

public struct PositionReportingView<Content: View>: View {
	var coordinateSpace: CoordinateSpace
	@Binding var position: CGPoint
	@ViewBuilder var content: () -> Content
	
	public init(coordinateSpace: CoordinateSpace, position: Binding<CGPoint>, content: @escaping () -> Content) {
		self.coordinateSpace = coordinateSpace
		_position = position
		self.content = content
	}
	
	public var body: some View {
		content()
			.background(GeometryReader { proxy in
				clearBackground(using: proxy)
			})
	}
	
	func clearBackground(using proxy: GeometryProxy) -> some View {
		let offset = proxy.frame(in: coordinateSpace).origin
		DispatchQueue.main.async { position = offset }
		return Color.clear
	}
}
