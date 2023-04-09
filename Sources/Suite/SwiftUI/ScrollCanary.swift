//
//  ScrollCanary.swift
//  
//
//  Created by Ben Gottlieb on 4/8/23.
//

import SwiftUI

public struct ScrollCanary: View {
	@Binding var isScrolling: Bool
	@Binding var scrollOffset: CGSize
	@State private var initialFrame: CGRect = .zero
	@State private var clearScrollingTask: Task<Void, Never>?
	let trackIsScrolling: Bool
	let trackOffset: Bool
	
	public init(isScrolling: Binding<Bool>) {
		_isScrolling = isScrolling
		_scrollOffset = .constant(.zero)
		trackIsScrolling = true
		trackOffset = false
	}
	
	public init(scrollOffset: Binding<CGSize>) {
		_isScrolling = .constant(false)
		_scrollOffset = scrollOffset
		trackIsScrolling = false
		trackOffset = true
	}
	
	public var body: some View {
		Color.clear
			.frame(height: 1)
			.background( GeometryReader { geo -> Color in
				let newFrame = geo.frame(in: .global)
				
				if trackIsScrolling {
					if newFrame.origin.y != initialFrame.origin.y {
						DispatchQueue.main.async {
							initialFrame = newFrame
							isScrolling = true
							clearScrollingTask?.cancel()
							clearScrollingTask = Task.detached() {
								do {
									try await Task.sleep(nanoseconds: 300_000_000)
									isScrolling = false
								} catch { }
							}
						}
					}
				} else if trackOffset {
					scrollOffset = CGSize(width: newFrame.minX - initialFrame.minX, height: newFrame.minY - initialFrame.minY)
				}
				
				return Color.clear
			})
			.background( GeometryReader { geo in
				Color.clear
					.onAppear {
						initialFrame = geo.frame(in: .global)
					}
			})
	}
}
