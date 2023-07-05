//
//  Animation.swift
//
//
//  Created by Ben Gottlieb on 7/5/23.
//

import SwiftUI


@available(iOS 17.0, *)
public func withAnimationOnMain<Result>(_ animation: Animation? = .default, completionCriteria: AnimationCompletionCriteria = .logicallyComplete, _ body: @escaping () -> Result, completion: @escaping () -> Void) {
	if Thread.isMainThread {
		_ = withAnimation(animation, completionCriteria: completionCriteria, body, completion: completion)
	} else {
		Task {
			await MainActor.run {
				withAnimation(animation, completionCriteria: completionCriteria, body, completion: completion)
			}
		}
	}
}

public func withAnimationOnMain<Result>(_ animation: Animation? = .default, _ body: @escaping () -> Result) {
	if Thread.isMainThread {
		_ = withAnimation(animation, body)
	} else {
		Task {
			await MainActor.run {
				withAnimation(animation, body)
			}
		}
	}
}
