//
//  RefreshableScrollView.swift
//  PullToRefresh
//
//  Created by ben on 1/17/21.
//

#if canImport(SwiftUI)
#if canImport(Combine)
import SwiftUI

// Thanks to https://swiftui-lab.com/scrollview-pull-to-refresh/

public typealias DoneRefreshingCompletion = () -> Void
public typealias RefreshAction = (@escaping DoneRefreshingCompletion) -> Void

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public struct RefreshableScrollView<Content: View>: View {
	var scrollHeaderHeight: CGFloat
	var spinnerColor: Color
	@Binding var refreshing: Bool
	let content: Content
	let showsIndicators: Bool
    let isEnabled: Bool
    
	@State private var previousScrollOffset: CGFloat = 0
	@State private var scrollOffset: CGFloat = 0
	@State private var isLockedToTop: Bool = false
	@State private var percentDown: CGFloat = 0
	
    public init(isEnabled enabled: Bool = true, headerHeight: CGFloat = 50, color: Color = .gray, showsIndicators indicators: Bool = true, refreshing: Binding<Bool>, @ViewBuilder content builder: () -> Content) {
		scrollHeaderHeight = headerHeight
		spinnerColor = color
		_refreshing = refreshing
		showsIndicators = indicators
		content = builder()
        isEnabled = enabled
	}
	
	public var body: some View {
		return
			ScrollView(showsIndicators: showsIndicators) {
				ZStack(alignment: .top) {
                    if isEnabled { ScrollTrackingView() }
					
					VStack { content }.alignmentGuide(.top, computeValue: { d in (refreshing && isLockedToTop) ? -scrollHeaderHeight : 0.0 })
					
					HeaderView(color: spinnerColor, offset: scrollOffset, height: scrollHeaderHeight, loading: refreshing)
				}
			}
			.background(BoundsTrackingView())
			.onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
				updateRefreshHeader(with: values)
			}
		
	}
	
	func updateRefreshHeader(with values: [RefreshableKeyTypes.PrefData]) {
		DispatchQueue.main.async {
			let movingBounds = values.first { $0.vType == .scrollTracking }?.bounds ?? .zero
			let fixedBounds = values.first { $0.vType == .boundsTracking }?.bounds ?? .zero
			
			scrollOffset  = movingBounds.minY - fixedBounds.minY
			
			// Crossing the scrollHeaderHeight on the way down, we start the refresh process
			if !refreshing && (scrollOffset > scrollHeaderHeight && previousScrollOffset <= scrollHeaderHeight) {
				refreshing = true
			}
			
			if refreshing { 				// Crossing the scrollHeaderHeight on the way up, we add a space at the top of the scrollview
				if previousScrollOffset > scrollHeaderHeight && scrollOffset <= scrollHeaderHeight {
					isLockedToTop = true
				}
			} else { // remove the sapce at the top of the scroll view
				isLockedToTop = false
			}
			
			previousScrollOffset = scrollOffset
		}
	}
	
	struct HeaderView: View {
		let color: Color
        let offset: CGFloat
        let height: CGFloat
        let loading: Bool
		
		var body: some View {
			ActivityIndicatorView(color, fixed: loading ? nil : Double(min(offset / height, 1)))
				.medium()
                .padding((height - ActivityIndicatorView.mediumHeight))
				.offset(y: -offset)
		}
	}
	
	struct ScrollTrackingView: View {
		var body: some View {
			GeometryReader { geo in
				Color.clear
					.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .scrollTracking, bounds: geo.frame(in: .global))])
			}.frame(height: 0)
		}
	}
	
	struct BoundsTrackingView: View {
		var body: some View {
			GeometryReader { geo in
				Color.clear
					.preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(vType: .boundsTracking, bounds: geo.frame(in: .global))])
			}
		}
	}
}

struct RefreshableKeyTypes {
	enum ViewType: Int {
		case scrollTracking
		case boundsTracking
	}
	
	struct PrefData: Equatable {
		let vType: ViewType
		let bounds: CGRect
	}
	
	struct PrefKey: PreferenceKey {
		static var defaultValue: [PrefData] = []
		
		static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
			value.append(contentsOf: nextValue())
		}
	}
}
#endif
#endif
