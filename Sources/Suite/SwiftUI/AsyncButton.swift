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
	var spinnerScale: Double
	
	public init(action: @escaping () async throws -> Void, spinnerColor: Color? = nil, spinnerScale: Double = 1.0, @ViewBuilder label: @escaping () -> Label) {
		self.action = action
		self.label = label
		self.spinnerColor = spinnerColor ?? .white
		self.spinnerScale = spinnerScale
	}
	
	@available(macOS 12.0, iOS 15.0, watchOS 8.0, *)
	public init(role: ButtonRole?, action: @escaping () async throws -> Void, spinnerColor: Color? = nil, spinnerScale: Double = 1.0, @ViewBuilder label: @escaping () -> Label) {
		self.action = action
		self.label = label
		self.role = role
		self.spinnerColor = spinnerColor ?? .white
		self.spinnerScale = spinnerScale
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
				label()
					.opacity(0.2)
			} else {
				label()
			}
		}
		.overlay(spinner)
	}
	
	@ViewBuilder var spinner: some View {
		if isPerformingAction {
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
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 8, *)
extension AsyncButton where Label == Text {
	public init(_ title: String, spinnerScale: Double = 1.0, action: @escaping () async throws -> Void) {
		self.action = action
		self.spinnerScale = spinnerScale
		self.label = { Text(title) }
	}
}

@available(macOS 12, iOS 15.0, tvOS 13, watchOS 8, *)
extension AsyncButton where Label == Text {
	public init(_ title: String, role: ButtonRole, spinnerScale: Double = 1.0, action: @escaping () async throws -> Void) {
		self.action = action
		self.role = role
		self.spinnerScale = spinnerScale
		self.label = { Text(title) }
	}
}
#endif
