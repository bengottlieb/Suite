//
//  Publishers.swift
//  
//
//  Created by Ben Gottlieb on 11/17/20.
//

#if canImport(Combine)
import Combine

@available(iOS 13.0, watchOS 6.0, OSX 10.15, *)
public extension Publisher {
	func logFailures(_ replacement: Output, label: String = "", completion: (() -> Void)? = nil) -> AnyPublisher<Output, Never> {
		self
			.catch { error -> Just<Output> in
				Swift.print("\(label) \(error)")
				completion?()
				return Just(replacement)
			}
			.assertNoFailure()
			.eraseToAnyPublisher()
	}
}
#endif
