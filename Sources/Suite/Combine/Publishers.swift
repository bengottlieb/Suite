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

@available(iOS 13.0, watchOS 6.0, OSX 10.15, *)
public extension Publisher {
	func sink(_ label: String = "PUB Error", completed: (() -> Void)? = nil, receiveValue: @escaping (Self.Output) -> Void) -> AnyCancellable {
		self.sink(receiveCompletion: { result in
			switch result {
			case .failure(let error): Swift.print("\(label): \(error)")
			case .finished: break
			}
			completed?()
		}, receiveValue: receiveValue)

	}
}

@available(iOS 13.0, watchOS 6.0, OSX 10.15, *)
extension AnyPublisher {
	static func just(_ output: Output) -> Self {
		Just(output)
			.setFailureType(to: Failure.self)
			.eraseToAnyPublisher()
	}
	
	static func fail(with error: Failure) -> Self {
		Fail(error: error).eraseToAnyPublisher()
	}
}

#endif
