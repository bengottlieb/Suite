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
public struct AsyncButton<Label: View, Busy: View>: View {
	var action: () async throws -> Void
	@ViewBuilder var label: () -> Label
	@ViewBuilder var  busy: () -> Busy
	
	@State private var isPerformingAction = false
	var role: Any?
	
	public init(action: @escaping () async throws -> Void, @ViewBuilder label: @escaping () -> Label, @ViewBuilder busy: @escaping () -> Busy) {
		self.action = action
		self.label = label
		self.busy = busy
	}
	
	@available(macOS 12.0, iOS 15.0, watchOS 8.0, *)
	public init(role: ButtonRole?, action: @escaping () async throws -> Void, @ViewBuilder label: @escaping () -> Label, @ViewBuilder busy: @escaping () -> Busy) {
		self.action = action
		self.label = label
		self.role = role
		self.busy = busy
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
				SuiteLogger.instance.log(error: error, "AsyncButton action failed", level: .loud)
			}
			await MainActor.run { isPerformingAction = false }
		}
	}
	
	var buttonLabel: some View {
		VStack {
			if isPerformingAction {
				busy()
			} else {
				label()
			}
		}
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 8, *)
extension AsyncButton where Label == Text, Busy == AsyncButtonBusyLabel {
	public init(_ title: String, spinnerScale: Double = 1.0, action: @escaping () async throws -> Void) {
		self.action = action
		self.label = { Text(title) }
		self.busy = { AsyncButtonBusyLabel(title: title, spinnerScale: spinnerScale) }
	}
}

@available(macOS 12, iOS 15.0, tvOS 13, watchOS 8, *)
extension AsyncButton where Label == Text, Busy == AsyncButtonBusyLabel {
	public init(_ title: String, role: ButtonRole, spinnerScale: Double = 1.0, action: @escaping () async throws -> Void) {
		self.action = action
		self.role = role
		self.label = { Text(title) }
		self.busy = { AsyncButtonBusyLabel(title: title, spinnerScale: spinnerScale) }
	}
}

@available(macOS 12, iOS 15.0, tvOS 13, watchOS 8, *)
extension AsyncButton where Busy == AsyncButtonBusyLabel {
	public init(role: ButtonRole? = nil, action: @escaping () async throws -> Void, spinnerScale: Double = 1.0, label: @escaping () -> Label) {
		self.action = action
		self.role = role
		self.label = label
		self.busy = { AsyncButtonBusyLabel(title: "", spinnerScale: spinnerScale) }
	}
}

public struct AsyncButtonBusyLabel: View {
	let title: String
	var spinnerColor = Color.white
	var spinnerScale: Double

	public var body: some View {
		Text(title)
			.opacity(0.2)
			.overlay(spinner)

	}
	
	@ViewBuilder var spinner: some View {
		if #available(OSX 13, iOS 16, watchOS 9, *) {
			ProgressView()
				.scaleEffect(spinnerScale)
				.tint(spinnerColor)
		} else if #available(OSX 11, iOS 14.0, watchOS 7, *) {
			ProgressView()
				.scaleEffect(spinnerScale)
				.colorInvert()
		}
	}

}
#endif
