//
//  KeyboardSpacer.swift
//  
//
//  Created by Ben Gottlieb on 7/1/20.
//

#if canImport(SwiftUI)
#if canImport(Combine)
#if canImport(UIKit) && !os(watchOS)

import SwiftUI
import Combine

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public class KeyboardObserver: ObservableObject {
	public static let instance = KeyboardObserver()
	
	@Published public var visibleHeight: CGFloat = 0
	@Published public var animationDuration: TimeInterval = 0.2
	var cancellables = Set<AnyCancellable>()
	public var keyboardIsVisible: Bool { visibleHeight > 0 }

	init() {
		NotificationCenter.default
			.publisher(for: UIResponder.keyboardWillShowNotification)
			.compactMap { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
			.map { $0.height }
			.assign(to: \.visibleHeight, on: self)
			.store(in: &cancellables)
		
		NotificationCenter.default
			.publisher(for: UIResponder.keyboardWillShowNotification)
			.compactMap { $0.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval }
			.assign(to: \.animationDuration, on: self)
			.store(in: &cancellables)

		NotificationCenter.default
			.publisher(for: UIResponder.keyboardWillHideNotification)
			.map { _ in 0 }
			.assign(to: \.visibleHeight, on: self)
			.store(in: &cancellables)

		NotificationCenter.default
			.publisher(for: UIResponder.keyboardWillHideNotification)
			.compactMap { $0.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval }
			.assign(to: \.animationDuration, on: self)
			.store(in: &cancellables)
	}
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public struct KeyboardSpacer: View {
	public init(offset: CGFloat = 0) {
		self.offset = offset
	}
	
	let offset: CGFloat
	@ObservedObject var keyboard = KeyboardObserver.instance
	public var body: some View {
		Rectangle()
			.fill(Color.clear)
			.edgesIgnoringSafeArea(.bottom)
			.frame(height: max(keyboard.visibleHeight - offset, 0))
			.animation(Animation.easeOut(duration: keyboard.animationDuration), value: keyboard.visibleHeight)
	}
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
struct KeyboardObserver_Previews: PreviewProvider {
	static var previews: some View {
		VStack() {
			Spacer()
			TextField("Enter your text", text: .constant(""))
			KeyboardSpacer()
		}
	}
}

#endif
#endif
#endif
