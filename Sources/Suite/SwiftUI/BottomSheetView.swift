//
//  OverlayModifer.swift
//  
//
//  Created by Ben Gottlieb on 6/30/21.
//

#if canImport(Combine)

import SwiftUI
import Studio

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public  struct SimpleOverlayModifer<Overlay: View>: ViewModifier {
	@Binding var isPresented: Bool
	@ViewBuilder var overlayBuilder: () -> Overlay
	
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
	@ViewBuilder var overlayBuilder: (Item) -> Overlay
	
	init(item: Binding<Item?>, @ViewBuilder overlay: @escaping (Item) -> Overlay) {
		self._item = item
		self.overlayBuilder = overlay
	}
	
	public func body(content: Content) -> some View {
		content.overlay(item == nil ? nil : overlayBuilder(item!))
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension View {
	func presentDimmedOverlay<Content: View, Item>(item: Binding<Item?>, @ViewBuilder overlayBuilder: @escaping (Item) -> Content) -> some View {
		blur(radius: item.wrappedValue == nil ? 0 : 3)
	//		.animation(.linear)
			.allowsHitTesting(item.wrappedValue == nil)
			.onTapGesture {
				print("Hhello")
			}
			.modifier(OverlayModifer(item: item, overlay: overlayBuilder))
	}
	
	func presentBottomSheet<Content: View, Item>(item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Content) -> some View {
		presentDimmedOverlay(item: item) { item in
			BottomSheet() { content(item) }
		}
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct BottomSheet<Content: View>: View {
	@ViewBuilder var content: () -> Content
	
	public var body: some View {
		GeometryReader() { geo in
			VStack() {
				Spacer()
				content()
					.padding(.bottom, geo.safeAreaInsets.bottom)
					.cornerRadius(16)
			}
			.edgesIgnoringSafeArea(.bottom)
		}
		.animation(.easeOut)
		.transition(.move(edge: .bottom))
	}
}


#endif
