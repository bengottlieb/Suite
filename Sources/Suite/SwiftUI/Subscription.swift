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
public var SubscriptionDictionary: [String: AnyCancellable] = [:]

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension AnyCancellable {
	static func unsequester(_ key: String? = nil, file: String = #file, function: String = #function) {
		SubscriptionDictionary.removeValue(forKey: key ?? "\(file)#\(function)")
	}
	
	@discardableResult
	func sequester(file: String = #file, function: String = #function) -> Self {
		let key = "\(file)#\(function)"
		assert(SubscriptionDictionary[key] == nil, "Already sequestered a subscription in \(file): \(function).")
		SubscriptionDictionary[key] = self
		return self
	}

	@discardableResult
	func sequester(_ key: String) -> Self {
		assert(SubscriptionDictionary[key] == nil, "Already sequestered a subscription using \(key).")
		SubscriptionDictionary[key] = self
		return self
	}

	@discardableResult
	func unsequester() -> Self {
		SubscriptionBag.remove(self)
		return self
	}
}

#endif
