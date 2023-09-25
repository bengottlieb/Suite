//
//  UnwrappedView.swift
//
//
//  Created by Ben Gottlieb on 9/25/23.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, watchOS 8.0, *)
public struct UnwrappedView<Target, Body: View>: View {
	@State var potential: Target?
	var buildBody: (Target) -> Body
	var buildTarget: () async throws -> Target?
	@State var showError = false
	@State var error: Error?

	public init(target: @escaping () async throws -> Target?, body: @escaping (Target) -> Body) {
		self.buildTarget = target
		self.buildBody = body
	}
	
	public var body: some View {
		Group {
			if let potential {
				buildBody(potential)
			} else if showError {
				if let error {
					Text(error.localizedDescription)
						.padding()
				} else {
					Text("Unable to display \(String(describing: Target.self))")
						.padding()
				}
			}
		}
		.task {
			do {
				potential = try await buildTarget()
			} catch {
				self.error = error
			}
			showError = true
		}
	}
}
