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
			PositionObservingView(
				coordinateSpace: .named(coordinateSpaceName),
				position: Binding(
					get: { offset },
					set: { newOffset in
						offset = CGPoint(x: -newOffset.x, y: -newOffset.y)
					}
				),
				content: content
			)
		}
		.coordinateSpace(name: coordinateSpaceName)
	}
}
struct PositionObservingView<Content: View>: View {
	var coordinateSpace: CoordinateSpace
	@Binding var position: CGPoint
	@ViewBuilder var content: () -> Content
	
	var body: some View {
		content()
			.background(GeometryReader { proxy in
				Color.clear.preference(
					key: PreferenceKey.self,
					value: proxy.frame(in: coordinateSpace).origin
				)
			})
			.onPreferenceChange(PreferenceKey.self) { position in
				self.position = position
			}
	}
}

private extension PositionObservingView {
	struct PreferenceKey: SwiftUI.PreferenceKey {
		static var defaultValue: CGPoint { .zero }
		
		static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
	}
}
