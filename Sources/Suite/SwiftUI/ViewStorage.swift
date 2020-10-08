//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 10/9/20.
//

#if canImport(SwiftUI)

import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class ViewStorage: ObservableObject {
	var views: [String: AnyView] = [:]
	
	public enum StandardView: String { case config, display, settings, modify
		var keyValue: String { "_StandardView_" + rawValue }
		
	}
	
	public init() {
		
	}
	
	public func clear(_ key: StandardView) {
		self.clear(key.keyValue)
	}
	
	public func clear(_ key: String) {
		guard self.views[key] != nil else { return }
		self.views.removeValue(forKey: key)
		
		self.objectWillChange.send()
	}
	
	public func store<Target: View>(_ view: Target, for key: StandardView) {
		store(view, for: key.keyValue)
		self.objectWillChange.send()
	}
	
	public func view(for key: StandardView) -> AnyView? {
		views[key.keyValue]
	}

	public func store<Target: View>(_ view: Target, for key: String) {
		views[key] = view.anyView()
		self.objectWillChange.send()
	}
	
	public func view(for key: String) -> AnyView? {
		views[key]
	}
}

#endif
