//
//  LoadingView.swift
//
//
//  Created by Ben Gottlieb on 9/25/23.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, watchOS 8.0, *)
public struct LoadingView<Target, Body: View, LoadingBody: View, ErrorBody: View>: View {
	@State var state: LoadingState<Target> = .idle
	@ViewBuilder var buildBody: (Target) -> Body
	@ViewBuilder var loadingBody: () -> LoadingBody
	var buildTarget: () async throws -> Target?
	@ViewBuilder var failedBody: (Error?) -> ErrorBody
	@State var showError = false
	@State var error: Error?

	public init(target: @escaping () async throws -> Target?, @ViewBuilder loading: @escaping () -> LoadingBody, @ViewBuilder failed: @escaping (Error?) -> ErrorBody, @ViewBuilder body: @escaping (Target) -> Body) {
		self.buildTarget = target
		self.buildBody = body
		self.loadingBody = loading
		self.failedBody = failed
	}
	
	public var body: some View {
		VStack {
			switch state {
			case .idle:
				EmptyView()
					
			case .loading:
				loadingBody()
				
			case .empty:
				failedBody(nil)
				
			case .loaded(let content):
				buildBody(content)
				
			case .failed(let error):
				failedBody(error)
			}
		}
		.task {
			state = .loading
			do {
				if let result = try await buildTarget() {
					state = .loaded(result)
				} else {
					state = .empty
				}
			} catch {
				state = .failed(error)
			}
			showError = true
		}
	}
}

@available(iOS 15.0, macOS 12.0, watchOS 8.0, *)
public extension LoadingView where ErrorBody == SimpleErrorMessageView {
	init(target: @escaping () async throws -> Target?, @ViewBuilder loading: @escaping () -> LoadingBody, @ViewBuilder body: @escaping (Target) -> Body) {
		self.buildTarget = target
		self.buildBody = body
		self.loadingBody = loading
		self.failedBody = { error in
			SimpleErrorMessageView(error: error, fallbackText: "Failed to load \(String(describing: Target.self))")
		}
	}
}

@available(iOS 15.0, macOS 12.0, watchOS 8.0, *)
public extension LoadingView where LoadingBody == SimpleProgressView {
	init(loadingLabel: String? = nil, target: @escaping () async throws -> Target?, @ViewBuilder failed: @escaping (Error?) -> ErrorBody, @ViewBuilder body: @escaping (Target) -> Body) {
		self.buildTarget = target
		self.buildBody = body
		self.loadingBody = {
			SimpleProgressView(label: loadingLabel)
		}
		self.failedBody = failed
	}
}

@available(iOS 15.0, macOS 12.0, watchOS 8.0, *)
public extension LoadingView where LoadingBody == SimpleProgressView, ErrorBody == SimpleErrorMessageView {
	init(loadingLabel: String? = nil, target: @escaping () async throws -> Target?, @ViewBuilder body: @escaping (Target) -> Body) {
		self.buildTarget = target
		self.buildBody = body
		self.loadingBody = {
			SimpleProgressView(label: loadingLabel)
		}
		self.failedBody = { error in
			SimpleErrorMessageView(error: error, fallbackText: "Failed to load \(String(describing: Target.self))")
		}
	}
}
