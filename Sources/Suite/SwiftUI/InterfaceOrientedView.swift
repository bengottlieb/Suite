//
//  ScreenOrientedView.swift
//
//  Created by ben on 4/6/20.
//  Copyright © 2020 Ben Gottlieb. All rights reserved.
//

#if canImport(Combine)
import SwiftUI
import Combine
import Suite

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
class OrientationWatcher: ObservableObject, CustomStringConvertible {
	static var instance = OrientationWatcher()
	
	static func setup(windowScene: UIWindowScene) {
		self.instance = OrientationWatcher(initialOrientation: windowScene.interfaceOrientation)
	}
	
	init(initialOrientation: UIInterfaceOrientation = .unknown) {
		self.orientation = initialOrientation
		self.subscription = UIDevice.orientationDidChangeNotification.publisher()
			.sink() { device in
				if let newOrientation = UIApplication.shared.currentScene?.interfaceOrientation, newOrientation != self.orientation {
					self.orientation = newOrientation
				}
			}.sequester().unsequester()
	}
	
	@Published var orientation: UIInterfaceOrientation
	private var subscription: AnyCancellable!
	
	var isLandscape: Bool { return self.orientation.isLandscape }
	var description: String { return self.isLandscape ? "Landscape" : "Portrait" }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
struct InterfaceOrientedView<Contents: View>: View {
	@ObservedObject var orientationWatcher = OrientationWatcher.instance
	
	let contents: () -> Contents
	
    var body: some View {
		contents()
			.id(orientationWatcher.isLandscape)
	}
}

#endif
