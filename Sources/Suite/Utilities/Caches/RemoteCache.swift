//
//  RemoteCache.swift
//  
//
//  Created by ben on 1/7/21.
//

import Foundation

#if canImport(Combine)
import Combine


@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class RemoteCache<Element: Cachable>: Cache<Element> {
	let session: URLSession
	
	public init(session urlSession: URLSession = .shared) {
		session = urlSession
		super.init(backingCache: nil)
	}
	
	public override func fetch(for url: URL, behavior: CachePolicy = .normal) -> AnyPublisher<Element, Error> {
		if behavior == .skipRemote { return Fail(outputType: Element.self, failure: CacheError.noLocalItemFound).eraseToAnyPublisher() }

		return session.dataTaskPublisher(for: url)
			.tryMap { output in
				if let result = Element.create(with: output.data) as? Element { return result }
				throw CacheError.failedToUnCache
			}
			.eraseToAnyPublisher()
	}
}



#endif
