//
//  AsyncButton.swift
//  
//
//  Created by Ben Gottlieb on 1/5/22.
//

#if canImport(Combine)
import SwiftUI

public struct ButtonIsPerformingActionKey: PreferenceKey {
	public static var defaultValue = false
	public static func reduce(value: inout Bool, nextValue: () -> Bool) {
		value = value || nextValue()
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct AsyncButton<Label: View>: View {
	var action: () async throws -> Void
	var spinnerColor = Color.white
	@ViewBuilder var label: () -> Label
	
	@State private var isPerformingAction = false
	var role: Any?
	
	public init(action: @escaping () async throws -> Void, spinnerColor: Color? = nil, @ViewBuilder label: @escaping () -> Label) {
		self.action = action
		self.label = label
		self.spinnerColor = spinnerColor ?? .white
	}
	
	@available(macOS 12.0, iOS 15.0, watchOS 8.0, *)
	public init(role: ButtonRole?, action: @escaping () async throws -> Void, spinnerColor: Color? = nil, @ViewBuilder label: @escaping () -> Label) {
		self.action = action
		self.label = label
		self.role = role
		self.spinnerColor = spinnerColor ?? .white
	}
	
	public var body: some View {
		if #available(macOS 12.0, iOS 15.0, watchOS 8.0, *) {
			Button(role: role as? ButtonRole, action: { performAction() }) { buttonLabel }
				.disabled(isPerformingAction)
				.preference(key: ButtonIsPerformingActionKey.self, value: isPerformingAction)
		} else {
			Button(action: { performAction() }) { buttonLabel }
				.disabled(isPerformingAction)
				.preference(key: ButtonIsPerformingActionKey.self, value: isPerformingAction)
		}
	}
	
	func performAction() {
		Task.detached {
			isPerformingAction = true
			do {
				try await action()
			} catch {
				SuiteLogger.instance.log(error: error, "AsyncButton action failed")
			}
			await MainActor.run { isPerformingAction = false }
		}
	}
	
	var buttonLabel: some View {
		ZStack {
			if isPerformingAction {
				label().opacity(0)
				if #available(OSX 11, iOS 14.0, watchOS 7, *) {
					ProgressView()
						.colorInvert()
						.scaleEffect(0.5)
				} else {
					label().opacity(0.2)
				}
			} else {
				label()
			}
		}
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 8, *)
extension AsyncButton where Label == Text {
	public init(_ title: String, action: @escaping () async throws -> Void) {
		self.action = action
		self.label = { Text(title) }
	}
}

@available(macOS 12, iOS 15.0, tvOS 13, watchOS 8, *)
extension AsyncButton where Label == Text {
	public init(_ title: String, role: ButtonRole, action: @escaping () async throws -> Void) {
		self.action = action
		self.role = role
		self.label = { Text(title) }
	}
}
#endif
