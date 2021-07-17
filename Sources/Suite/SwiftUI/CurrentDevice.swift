//
//  CurrentDevice.swift
//  
//
//  Created by Ben Gottlieb on 5/28/20.
//

#if canImport(Combine)
#if os(iOS)
import UIKit
import SwiftUI
import Studio

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
@available(iOSApplicationExtension, unavailable)
public class CurrentDevice: ObservableObject {
	public static let instance = CurrentDevice()

	@Published public var isLandscape = false
	@Published public var screenSize = UIScreen.main.bounds.size
	@Published public var safeAreaInsets = UIEdgeInsets.zero
	
	public let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
	public let isIPad = UIDevice.current.userInterfaceIdiom == .pad

	private init() {
		UIDevice.current.beginGeneratingDeviceOrientationNotifications()
		
		self.isLandscape = UIDevice.current.orientation.isLandscape
		self.safeAreaInsets = UIApplication.shared.currentWindow?.rootViewController?.view.safeAreaInsets ?? .zero
		NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
	}
	
	@objc func orientationChanged() {
		DispatchQueue.main.async {
			if UIDevice.current.orientation == .unknown { return }
			self.isLandscape = UIDevice.current.orientation.isLandscape
			self.screenSize = UIScreen.main.bounds.size
			self.safeAreaInsets = UIApplication.shared.currentWindow?.rootViewController?.view.safeAreaInsets ?? .zero
		}
	}
}
#endif
#endif
