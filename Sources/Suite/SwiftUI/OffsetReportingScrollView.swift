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
	@Binding var offset: CGFloat
	@ViewBuilder var content: () -> Content
	
	private let coordinateSpaceName = UUID()
	
	public init(_ axes: Axis.Set = [.vertical], showsIndicators: Bool = true, offset: Binding<CGFloat>, content: @escaping () -> Content) {
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
						offset = -newOffset
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
	@Binding var position: CGFloat
	@ViewBuilder var content: () -> Content
	
	public init(coordinateSpace: CoordinateSpace, position: Binding<CGFloat>, content: @escaping () -> Content) {
		self.coordinateSpace = coordinateSpace
		_position = position
		self.content = content
	}
	
	public var body: some View {
		content()
			.background(GeometryReader { proxy in
				let offset = proxy.frame(in: coordinateSpace).origin
				Color.clear
					.preference(key: PreferenceKey.self, value: offset.y)
			})
			.onPreferenceChange(PreferenceKey.self) { position in
				_ = print("new position: \(position)")
				self.position = position
			}
	}
}

private extension PositionReportingView {
	struct PreferenceKey: SwiftUI.PreferenceKey {
		static var defaultValue: CGFloat { .zero }
		
		static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
	}
}
