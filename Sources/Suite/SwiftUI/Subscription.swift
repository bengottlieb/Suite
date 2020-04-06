//
//  Subscription.swift
//  
//
//  Created by Ben Gottlieb on 3/22/20.
//

#if canImport(Combine)

import Combine


@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public var SubscriptionBag = Set<AnyCancellable>()

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension AnyCancellable {
	@discardableResult
	func sequester() -> Self {
		self.store(in: &SubscriptionBag)
		return self
	}

	@discardableResult
	func unsequester() -> Self {
		SubscriptionBag.remove(self)
		return self
	}
}

#endif
