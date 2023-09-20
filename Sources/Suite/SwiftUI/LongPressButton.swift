//
//  LongPressButton.swift
//
//
//  Created by Ben Gottlieb on 8/29/23.
//

import SwiftUI

public struct LongPressButton<Label: View>: View {
	let action: () async throws -> Void
	let longPress: () async throws -> Void
	let delay: TimeInterval
	let tolerance: CGFloat
	
	let label: () -> Label
	
	@State private var longPressStartedAt: Date!
	@State private var longPressInvalidated = false
	@State private var longPressTriggered = false
	@State private var timeOutTask: Task<Void, Never>?
	
	public init(delay: TimeInterval = 0.5, tolerance: CGFloat = 10.0, action: @escaping () async throws -> Void, longPress: @escaping () async throws -> Void = { }, label: @escaping () -> Label) {
		self.action = action
		self.longPress = longPress
		self.label = label
		self.delay = delay
		self.tolerance = tolerance
	}
	
	func cancelTimeOut() {
		timeOutTask?.cancel()
		timeOutTask = nil
	}

	func pressed() {
		if longPressTriggered {
			longPressTriggered = false
			return
		}
		Task {
			do {
				try await action()
			} catch {
				logg("Button press failed: \(error)")
			}
		}
	}
	
	func longPressed() {
		cancelTimeOut()
		longPressTriggered = true
		Task {
			do {
				try await longPress()
			} catch {
				logg("Button long press failed: \(error)")
			}
		}
		longPressInvalidated = true
	}
	
	public var body: some View {
		Button(action: { pressed() }) {
			label()
		}
		.simultaneousGesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
			.onChanged { value in
				if longPressStartedAt == nil {
					longPressStartedAt = Date()
					longPressInvalidated = false
					longPressTriggered = false
					timeOutTask = Task {
						do {
							try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * delay))
							longPressStartedAt = nil
							longPressed()
						} catch { }
					}
				}
				
				if !longPressInvalidated, abs(longPressStartedAt.timeIntervalSinceNow) > delay {
					longPressed()
				} else if !longPressInvalidated {
					let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
					
					if distance > tolerance {
						cancelTimeOut()
						longPressInvalidated = true
					}
				}
			}
			.onEnded{ value in
				cancelTimeOut()
				longPressStartedAt = nil
			}
		)
	}
}

