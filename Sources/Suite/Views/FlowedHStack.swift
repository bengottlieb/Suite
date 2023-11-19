//
//  SwiftUIView.swift
//
//
//  Created by Ben Gottlieb on 10/15/23.
//

import SwiftUI

extension String: FlowedHStackElement {
	public var isNewLine: Bool { self == "\n" }
	public var offset: CGSize { .zero }
	public var body: some View { Text(self) }
}

public protocol FlowedHStackElement: View {
	var isNewLine: Bool { get }
	var offset: CGSize { get }
	
}
public protocol FlowedHStackImageElement: Identifiable { }

public struct FlowedHStackImage: View, FlowedHStackImageElement {
	public let id = UUID()
	public let image: Image
	public var body: some View {
		image.renderingMode(.template)
			.offset(y: -0.5)
	}
}

public struct FlowSizeKey: PreferenceKey {
	public static var defaultValue: [CGSize] = []
	public static func reduce(value: inout [CGSize], nextValue: () -> [CGSize]) {
		value.append(contentsOf: nextValue())
	}
}

public struct FlowedHStackNewLineView: View {
	public var body: some View { Color.clear.frame(width: 0, height: 12) }
}

public struct FlowedHStack<Element: FlowedHStackElement, ElementView: View>: View {
	public init(_ elements: [Element], hSpacing: Double = 2, vSpacing: Double = 2, content: @escaping (Element) -> ElementView) {
		self.elements = elements
		horizontalSpacing = hSpacing
		verticalSpacing = vSpacing
		elementViews = elements.map { content($0) }
	}
	
	let elements: [Element]
	let horizontalSpacing: Double
	let verticalSpacing: Double
	let elementViews: [ElementView]
	
	@State private var availableWidth: CGFloat = 0.0
	@State private var elementSizes: [CGSize] = []
	@State private var totalHeight = 0.0
	
	func layout(sizes: [CGSize], spacing proposedSpacing: CGSize? = nil) -> [CGPoint] {
		let spacing = proposedSpacing ?? .init(width: horizontalSpacing, height: verticalSpacing)
		var rows: [[CGSize]] = []
		var origins: [CGPoint] = []
		var currentRow: [CGSize] = []
		var currentSize: CGSize = .zero
		
		for size in sizes {
			if (currentSize.width + size.width + spacing.width) >= availableWidth, !currentRow.isEmpty {
				currentSize = .zero
				rows.append(currentRow)
				currentRow = []
			}
			
			currentRow.append(size)
			currentSize.width += (size.width + spacing.width)
			currentSize.height = max(currentSize.height, size.height)
		}
		if !currentRow.isEmpty { rows.append(currentRow) }
		
		currentSize = .zero
		for row in rows {
			let rowHeight = row.map { $0.height }.max() ?? 0
			
			for rowItem in row {
				let yOffset = (rowHeight - rowItem.height) / 2
				origins.append(CGPoint(x: currentSize.width, y: currentSize.height + yOffset))
				currentSize.width += rowItem.width + spacing.width
			}
			currentSize.height += rowHeight + spacing.height
			currentSize.width = 0
		}
		
		return origins
	}
	
	public var body: some View {
		let offsets = layout(sizes: elementSizes)
		
		VStack(spacing: 0) {
			GeometryReader { proxy in
				Color.clear.preference(key: FlowSizeKey.self, value: [proxy.size])
			}
			.frame(height: 0)
			.onPreferenceChange(FlowSizeKey.self) { sizes in availableWidth = sizes.first?.width ?? 0.0 }
			
			ZStack(alignment: .topLeading) {
				ForEach(Array(zip(elements, elements.indices)), id: \.1) { element, index in
					elementViews[index]
						.fixedSize()
						.background(GeometryReader { proxy in
							Color.clear.preference(key: FlowSizeKey.self, value: [proxy.size])
						})
						.alignmentGuide(.leading, computeValue: { dimension in
							guard index < offsets.count else { return 0 }
							return -offsets[index].x
						})
						.alignmentGuide(.top, computeValue: { dimension in
							guard index < offsets.count else { return 0 }
							return -offsets[index].y
						})
					//.border(Color.gray, width: 0.5)
				}
			}
			.onPreferenceChange(FlowSizeKey.self) { sizes in elementSizes = sizes }
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
		}
		//.border(Color.red)
	}
}

public extension FlowedHStack where Element == String, ElementView == Text {
	init(_ elements: [Element], hSpacing: Double = 2, vSpacing: Double = 2) {
		self.elements = elements
		horizontalSpacing = hSpacing
		verticalSpacing = vSpacing
		elementViews = elements.map { item in Text(item) }
	}

}
