//
//  CurrentDevice.swift
//  
//
//  Created by Ben Gottlieb on 5/28/20.
//

#if canImport(Combine)
import UIKit
import SwiftUI
import Studio

@available(OSX 10.15, iOS 13.0, *)
public class CurrentDevice: ObservableObject {
	public static let instance = CurrentDevice()

	@Published public var isLandscape = false
	@Published public var screenSize = UIScreen.main.bounds.size
	
	public let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
	public let isIPad = UIDevice.current.userInterfaceIdiom == .pad

	private init() {
		UIDevice.current.beginGeneratingDeviceOrientationNotifications()
		
		self.isLandscape = UIDevice.current.orientation.isLandscape
		NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
	}
	
	@objc func orientationChanged() {
		DispatchQueue.main.async {
			self.isLandscape = UIDevice.current.orientation.isLandscape
			self.screenSize = UIScreen.main.bounds.size
		}
	}
}
#endif
