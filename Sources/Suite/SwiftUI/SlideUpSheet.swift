//
//  SlideUpSheet.swift
//  Internal
//
//  Created by Ben Gottlieb on 7/20/20.
//  Copyright © 2020 Stand Alone, Inc. All rights reserved.
//

#if canImport(Combine)
import SwiftUI
import Combine

#if canImport(UIKit) && !os(watchOS)
	import UIKit
#endif
#if canImport(AppKit)
	import AppKit
#endif

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class SlideUpManager: ObservableObject {
	public var isSheetVisible = false { willSet { self.objectWillChange.send() }}

	public init() {
		
	}
	
	@Published public var currentSheet: AnyView?
	
	public func hide() {
		self.isSheetVisible = false
	}
	
	public func show(_ view: AnyView) {
		self.currentSheet = view
		
		DispatchQueue.main.async() {
			withAnimation {
				self.isSheetVisible = true
			}
		}
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
struct SlideUpSheetPresentation: EnvironmentKey {
	static let defaultValue: Binding<Bool> = .constant(true)
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension EnvironmentValues {
	 public var slideUpSheetPresentation: Binding<Bool> {
		  get {
				return self[SlideUpSheetPresentation.self]
		  }
		  set {
				self[SlideUpSheetPresentation.self] = newValue
		  }
	 }
}


@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
@available(iOSApplicationExtension, unavailable)
public struct SlideUpSheet<Content: View>: View {
	public enum DragStyle { case handle, noHandle, noDrag }
	let dragStyle: DragStyle
	let blockBackground: Bool
	@Binding var show: Bool
	@State var dragOffset = CGSize.zero
	@State var backgroundAlpha = 0.0
	let content: () -> Content
	let radius: CGFloat
	
	#if canImport(UIKit) && !os(watchOS)
		@ObservedObject var device = CurrentDevice.instance

		var backgroundColor = Color(UIColor.secondarySystemBackground)
		var screenHeight: CGFloat { device.screenSize.height }
	#elseif canImport(AppKit)
		var backgroundColor = Color(NSColor.windowBackgroundColor)
	var screenHeight: CGFloat = 1024
	#else
		var backgroundColor = Color.white
		var screenHeight: CGFloat = 1024
	#endif

	public init(show: Binding<Bool>, dragStyle: DragStyle = .handle, blockBackground: Bool = true, backgroundColor: Color? = nil, @ViewBuilder content: @escaping () -> Content) {
		_show = show
		self.dragStyle = dragStyle
		self.blockBackground = blockBackground
		self.content = content
		self.radius = 10
		if let color = backgroundColor { self.backgroundColor = color }
	}

	public var body: some View {
		ZStack() {
			if blockBackground {
				Rectangle()
					.fill(Color.black.opacity(0.4))
					.onTapGesture {
						withAnimation() { self.show.toggle() }
					}
					.opacity(show ? backgroundAlpha : 0.0)
					.edgesIgnoringSafeArea(.all)
			}
			
			ZStack() {
				VStack() {
					Spacer()
					ZStack() {
						RoundedRectangle(cornerRadius: radius)
							.fill(backgroundColor)

						RoundedRectangle(cornerRadius: radius)
							.stroke(Color.black)

						VStack(spacing: 0) {
								if dragStyle == .handle {
									HStack() {
										Spacer()
										RoundedRectangle(cornerRadius: 3)
											.fill(Color.gray)
											.frame(width: 40, height: 5)
											.padding()
										Spacer()
									}
								} else {
									Rectangle()
										.fill(Color.clear)
										.frame(height: 14)
								}
							
							Rectangle()
								.fill(Color.clear)
								.frame(maxHeight: 1)
							
							content()
						}
						.padding([.bottom, .leading, .trailing])
						.layoutPriority(1)
					}
				}
			}
			.clipped()
			.shadow(color: .black, radius: 5, x: 3, y: 3)
			.padding()
			.offset(y: show ? dragOffset.height : screenHeight * 2)
			.animation(.default)
			.transition(.slide)
			.gesture(
				DragGesture()
					.onChanged{ value in
						self.dragOffset.height = max(value.translation.height, 0)
					}
					.onEnded { value in
						if self.dragOffset.height > 100, self.dragStyle != .noDrag {
							self.show = false
							self.dragOffset = .zero
						} else {
							self.dragOffset = .zero
						}
					}
			)
		}
		.environment(\.slideUpSheetPresentation, $show)
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
@available(iOSApplicationExtension, unavailable)
struct SlideUpSheet_Previews: PreviewProvider {
	static var previews: some View {
		SlideUpSheet(show: .constant(true)) {
			VStack() {
				ForEach(0..<10) { _ in
					Text("Hello")
				}
			}
			
		}
	}
}
#endif
