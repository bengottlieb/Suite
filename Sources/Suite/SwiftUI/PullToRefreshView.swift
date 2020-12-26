//
//  PullToRefreshIndicator.swift
//  
//
//  Created by Ben Gottlieb on 12/17/20.
//

#if canImport(Combine)
#if canImport(UIKit)

import SwiftUI
import UIKit

#if os(iOS)
@available(iOS 13.0, *)
public struct PullToRefreshIndicator: View {
	let refresh: (@escaping () -> Void) -> Void
	let spinnerColor: Color
	public init(color: Color = .gray, refresh callback: @escaping (@escaping () -> Void) -> Void) {
		spinnerColor = color
		refresh = callback
	}
	
	func stopRefreshing() {
		self.percentFull = 0
		withAnimation() {
			self.isRefreshing = false
		}
	}
	
	static var safeAreaTop = (UIApplication.shared.currentWindow?.rootViewController?.view.safeAreaInsets.top ?? 20)
	var fullHeight: CGFloat = 50 + Self.safeAreaTop
	@State var percentFull = 0.0
	@State var isRefreshing = false
	
	public var body: some View {
		ZStack(alignment: .bottom) {
			GeometryReader() { proxy -> Color in
				let height = proxy.frame(in: .global).y / fullHeight
				DispatchQueue.main.async {
					percentFull = max(0, min(Double(height), 1))
					if percentFull >= 1.0, !isRefreshing {
						isRefreshing = true
						refresh() { stopRefreshing() }
					}
				}
				
				return Color.clear
			}
			.frame(height: isRefreshing ? fullHeight : 0)
			.layoutPriority(1)
			
			Group() {
				if isRefreshing {
					ActivityIndicatorView(spinnerColor).medium()
				} else {
					ActivityIndicatorView(spinnerColor, fixed: percentFull).medium()
				}
			}
			.padding(.bottom, 10)
			
		}
	}
}

#endif
#endif
#endif
