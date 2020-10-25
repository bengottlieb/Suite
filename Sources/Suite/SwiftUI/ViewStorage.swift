//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 10/9/20.
//

#if canImport(SwiftUI)
#if canImport(Combine)

import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class ViewStorage: ObservableObject {
	var views: [String: StoredView] = [:]
	
	public struct ViewKey: RawRepresentable {
		public var rawValue: String
		public init(rawValue: String) { self.rawValue = rawValue }

		public var keyValue: String { rawValue }

		public static let config = ViewKey(rawValue: "_config")
		public static let display = ViewKey(rawValue: "_display")
		public static let settings = ViewKey(rawValue: "_settings")
		public static let modify = ViewKey(rawValue: "_modify")
	}
	
	public init() {
		
	}
	
	struct StoredView: Comparable {
		let id = UUID()
		let date: Date = Date()
		let view: AnyView
		
		static func ==(lhs: StoredView, rhs: StoredView) -> Bool { lhs.id == rhs.id }
		static func <(lhs: StoredView, rhs: StoredView) -> Bool { lhs.date < rhs.date }
	}
	
	public func clear(_ key: ViewKey) {
		guard self.views[key.keyValue] != nil else { return }
		self.views.removeValue(forKey: key.keyValue)
		
		self.objectWillChange.send()
	}
	
	public func store<Target: View>(_ view: Target, for key: ViewKey) {
		views[key.keyValue] = StoredView(view: view.anyView())
		self.objectWillChange.send()
		self.objectWillChange.send()
	}
	
	public func view(for key: ViewKey) -> AnyView? {
		views[key.keyValue]?.view
	}
	
	public func isViewStored(for key: ViewKey) -> Bool { view(for: key) != nil }
	
	public var lastStoredView: AnyView? {
		views.values.sorted().last?.view
	}
}

#endif
#endif
