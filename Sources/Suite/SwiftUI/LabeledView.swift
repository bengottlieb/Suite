//
//  LabeledView.swift
//
//
//  Created by Ben Gottlieb on 12/3/23.
//

import SwiftUI

public struct ShowViewLabelsEnvironmentKey: EnvironmentKey {
	public static var defaultValue = false
}

public extension EnvironmentValues {
	var showViewLabels: Bool {
		get { self[ShowViewLabelsEnvironmentKey.self] }
		set { self[ShowViewLabelsEnvironmentKey.self] = newValue }
	}
}

public extension View {
	@ViewBuilder func debugLabel(_ label: String? = nil) -> some View {
		if #available(iOS 15.0, *) {
			DebugLabeledView(view: self, label: label ?? String(describing: self))
		} else {
			self
		}
	}
}

@available(iOS 15.0, *)
struct DebugLabeledView<Content: View>: View {
	let view: Content
	let label: String
	@Environment(\.showViewLabels) var showViewLabels
	
	var body: some View {
		if showViewLabels {
			view
				.overlay(alignment: .topLeading) {
					Text(label)
						.font(.system(size: 9, weight: .semibold, design: .rounded))
						.foregroundStyle(.yellow)
						.padding(2)
						.background(.red)
				}
		} else {
			view
		}
	}
}
