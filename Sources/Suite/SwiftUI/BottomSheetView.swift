//
//  OverlayModifer.swift
//  
//
//  Created by Ben Gottlieb on 6/30/21.
//

#if canImport(Combine)
#if !os(visionOS)
import SwiftUI
import Studio

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct SimpleOverlayModifer<Overlay: View>: ViewModifier {
	@Binding var isPresented: Bool
	
	#if swift(>=5.4)
		@ViewBuilder var overlayBuilder: () -> Overlay
	#else
		var overlayBuilder: () -> Overlay
	#endif
	
	init(isPresented: Binding<Bool>, @ViewBuilder overlay: @escaping () -> Overlay) {
		self._isPresented = isPresented
		self.overlayBuilder = overlay
	}
	
	public func body(content: Content) -> some View {
		content.overlay(isPresented ? overlayBuilder() : nil)
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public  struct OverlayModifer<Overlay: View, Item>: ViewModifier {
	@Binding var item: Item?
	#if swift(>=5.4)
		@ViewBuilder var overlayBuilder: (Item) -> Overlay
	#else
		var overlayBuilder: (Item) -> Overlay
	#endif
	
	init(item: Binding<Item?>, @ViewBuilder overlay: @escaping (Item) -> Overlay) {
		self._item = item
		self.overlayBuilder = overlay
	}
	
	public func body(content: Content) -> some View {
		content.overlay(item == nil ? nil : overlayBuilder(item!))
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension OverlayModifer where Item == Int {
	init(isPresented: Binding<Bool>, @ViewBuilder overlay: @escaping () -> Overlay) {
		self._item = Binding<Int?>(get: { isPresented.wrappedValue ? 1 : nil }) { new in
			isPresented.wrappedValue = (new != nil)
		}
		self.overlayBuilder = { _ in overlay() }
	}
}

@available(OSX 11, iOS 14.0, tvOS 13, watchOS 6, *)
public extension View {
	func presentDimmedOverlay<Content: View, Item>(item: Binding<Item?>, tapToDismiss: Bool = true, animation: Animation = .linear, @ViewBuilder overlayBuilder: @escaping (Item) -> Content) -> some View {
		self
			.overlay(
				ZStack() {
					if item.wrappedValue != nil {
						Rectangle()
							.fill(Color.black.opacity(0.5))
							.ignoresSafeArea(.all)
							.onTapGesture {
								if tapToDismiss { withAnimation() { item.wrappedValue = nil } }
							}
							.transition(.opacity)
					}
				}
				.animation(animation)
			)
			.modifier(OverlayModifer(item: item, overlay: overlayBuilder))
	}
	
	func presentDimmedOverlay<Content: View>(isPresented: Binding<Bool>, tapToDismiss: Bool = true, animation: Animation = .linear, @ViewBuilder overlayBuilder: @escaping () -> Content) -> some View {
		self
			.overlay(
				ZStack() {
					if isPresented.wrappedValue {
						Rectangle()
							.fill(Color.black.opacity(0.5))
							.ignoresSafeArea(.all)
							.onTapGesture {
								if tapToDismiss { withAnimation() { isPresented.wrappedValue = false } }
							}
							.transition(.opacity)
					}
				}
				.animation(animation)
			)
			.modifier(OverlayModifer(isPresented: isPresented, overlay: overlayBuilder))
	}
	
	func presentBottomSheet<Content: View, Item>(item: Binding<Item?>, background: Color = .systemBackground, tapToDismiss: Bool = true, animation: Animation = .easeOut, @ViewBuilder content: @escaping (Item) -> Content) -> some View {
		presentDimmedOverlay(item: item, tapToDismiss: tapToDismiss, animation: animation) { item in
			BottomSheet(animation: animation, background) { content(item) }
		}
	}

	func presentBottomSheet<Content: View, Item, Background: View>(item: Binding<Item?>, animation: Animation = .easeOut, background: Background, @ViewBuilder content: @escaping (Item) -> Content) -> some View {
		presentDimmedOverlay(item: item, animation: animation) { item in
			BottomSheet(animation: animation, background) { content(item) }
		}
	}

	func presentBottomSheet<Content: View>(isPresented: Binding<Bool>, animation: Animation = .easeOut, background: Color = .systemBackground, @ViewBuilder content: @escaping () -> Content) -> some View {
		presentDimmedOverlay(isPresented: isPresented, animation: animation) {
			BottomSheet(background) { content() }
		}
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct BottomSheet<Content: View, Background: View>: View {
	var backgroundView: Background
	var content: () -> Content
	var animation: Animation
	
	public init(animation: Animation = .easeOut, _ background: Background, @ViewBuilder _ content: @escaping () -> Content) {
		self.backgroundView = background
		self.content = content
		self.animation = animation
	}

	public var body: some View {
		GeometryReader() { geo in
			VStack() {
				Spacer()
				content()
					.padding(.bottom, geo.safeAreaInsets.bottom)
					.background(backgroundView)
					.cornerRadius(16)
			}
			.edgesIgnoringSafeArea(.bottom)
		}
		.animation(animation)
		.transition(.move(edge: .bottom))
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension BottomSheet where Background == Color {
	public init(animation: Animation = .easeOut, _ background: Color = .systemBackground, _ content: @escaping () -> Content) {
		self.backgroundView = background
		self.content = content
		self.animation = animation
	}
}

#endif
#endif
