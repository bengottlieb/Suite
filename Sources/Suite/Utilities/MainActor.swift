//
//  Animation.swift
//
//
//  Created by Ben Gottlieb on 7/5/23.
//

import SwiftUI

extension MainActor {
	public static func run(_ block: @escaping () -> Void) {
		Task { await MainActor.run { block() }}
	}
}


@available(iOS 17.0, *)
public func withAnimationOnMain<Result>(_ animation: Animation? = .default, completionCriteria: AnimationCompletionCriteria = .logicallyComplete, _ body: @escaping () -> Result, completion: @escaping () -> Void) {
	if Thread.isMainThread {
		_ = withAnimation(animation, completionCriteria: completionCriteria, body, completion: completion)
	} else {
		MainActor.run { _ = withAnimation(animation, completionCriteria: completionCriteria, body, completion: completion) }
	}
}

public func withAnimationOnMain<Result>(_ animation: Animation? = .default, _ body: @escaping () -> Result) {
	if Thread.isMainThread {
		_ = withAnimation(animation, body)
	} else {
		MainActor.run { _ = withAnimation(animation, body) }
	}
}
