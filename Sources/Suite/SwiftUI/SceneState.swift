//
//  AppResumeObserver.swift
//  
//
//  Created by Ben Gottlieb on 8/25/21.
//

#if canImport(Combine)
#if canImport(UIKit)
import UIKit
import Combine
import SwiftUI

#if os(iOS)
public struct StateChange: OptionSet {
	public let rawValue: Int
	
	public init(rawValue: Int) { self.rawValue = rawValue }
	
	public static let appBecomeActive = 		StateChange(rawValue: 1 << 0)
	public static let appResignActive = 		StateChange(rawValue: 1 << 1)
	public static let appEnterForeground = 	StateChange(rawValue: 1 << 2)
	public static let appEnterBackground = 	StateChange(rawValue: 1 << 3)
	public static let sceneEnterForeground =	StateChange(rawValue: 1 << 4)
	public static let sceneEnterBackground = 	StateChange(rawValue: 1 << 5)
	public static let allOptions: [StateChange] = [.appBecomeActive, .appEnterBackground, .appResignActive, .appEnterBackground, .sceneEnterBackground, .sceneEnterForeground]
	
	var notificationName: Notification.Name? {
		switch self {
		case .appBecomeActive: return UIApplication.didBecomeActiveNotification
		case .appResignActive: return UIApplication.willResignActiveNotification
		case .appEnterForeground: return UIApplication.willEnterForegroundNotification
		case .appEnterBackground: return UIApplication.didEnterBackgroundNotification
		case .sceneEnterForeground: return UIScene.willEnterForegroundNotification
		case .sceneEnterBackground: return UIScene.didEnterBackgroundNotification
		default: return nil
		}
	}
	
	init?(_ name: Notification.Name) {
		switch name {
		case UIApplication.didBecomeActiveNotification: self = .appBecomeActive
		case UIApplication.willResignActiveNotification: self = .appResignActive
		case UIApplication.willEnterForegroundNotification: self = .appEnterForeground
		case UIApplication.didEnterBackgroundNotification: self = .appEnterBackground
		case UIScene.willEnterForegroundNotification: self = .sceneEnterForeground
		case UIScene.didEnterBackgroundNotification: self = .sceneEnterBackground
		default: return nil
		}
	}
}

@available(iOS 13.0, *)
struct ExitSceneView: View {
	let closure: () -> Void
	
	var body: some View {
		EmptyView()
			.onReceive(UIScene.didEnterBackgroundNotification.publisher()) { _ in
				closure()
			}
	}
}

@available(iOS 13.0, *)
extension View {
	public func onSceneExit(closure: @escaping () -> Void) -> some View {
		self
			.background(ExitSceneView(closure: closure))
	}
}


extension Array where Element == Notification.Name {
	func observe(closure: @escaping (Notification.Name) -> Void) -> [AnyCancellable] {
		map { name in
			name.publisher()
				.sink { _ in
					closure(name)
				}
		}
	}
}


@available(iOS 13.0, *)
public class SceneStateObserver: ObservableObject {
	var cancellables: [AnyCancellable] = []
	public var trigger = StateChange.appEnterForeground

	public init(which: StateChange = .appEnterForeground) {
		let names = StateChange.allOptions.filter { which.contains($0) }.compactMap { $0.notificationName }
		cancellables = names.observe { name in
			self.trigger = StateChange(name) ?? self.trigger
			DispatchQueue.main.async { self.objectWillChange.send() }
		}
	}
}
#endif
#endif
#endif
