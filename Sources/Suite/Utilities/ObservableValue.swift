//
//  ObservableValue.swift
//
//
//  Created by Ben Gottlieb on 5/14/20.
//

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
@dynamicMemberLookup
public final class ObservableValue<Value>: ObservableObject {
	@Published public private(set) var value: Value
	private var cancellable: AnyCancellable?
	
	public init<T: Publisher>(value: Value, publisher: T) where T.Output == Value, T.Failure == Never {
		self.value = value
		self.cancellable = publisher.assign(to: \.value, on: self)
	}

	public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
		self.value[keyPath: keyPath]
	}
}

#endif
