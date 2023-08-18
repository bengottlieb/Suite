//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 8/18/23.
//

import SwiftUI

@available(OSX 12, iOS 14.0, tvOS 13, watchOS 7, *)
public struct AsyncContainerView<Content: View, Blocker: View, ErrorView: View>: View {
	var function: () async throws -> Void
	var blocker: () -> Blocker
	var content: () -> Content
	var errorView: (Error) -> ErrorView
	
	@State var isLoaded = false
	@State var error: Error?

	public init(waitFor: @escaping () async throws -> Void, @ViewBuilder content: @escaping () -> Content, @ViewBuilder blocker: @escaping () -> Blocker, @ViewBuilder errorView: @escaping (Error) -> ErrorView) {
		function = waitFor
		self.blocker = blocker
		self.content = content
		self.errorView = errorView
	}
	
	public var body: some View {
		Group {
			if let error {
				errorView(error)
			} else if isLoaded {
				content()
			} else {
				blocker()
			}
		}
		.task {
			do {
				try await function()
				isLoaded = true
			} catch {
				self.error = error
			}
		}
	}
}

@available(OSX 12, iOS 14.0, tvOS 13, watchOS 7, *)
extension AsyncContainerView where ErrorView == ErrorDisplayingView {
	public init(waitFor: @escaping () async throws -> Void, @ViewBuilder content: @escaping () -> Content, @ViewBuilder blocker: @escaping () -> Blocker) {
		self.init(waitFor: waitFor, content: content, blocker: blocker) { error in
			ErrorDisplayingView(error: error)
		}
	}
}
