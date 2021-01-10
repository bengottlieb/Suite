//
//  InMemoryCache.swift
//  
//
//  Created by ben on 1/7/21.
//

import Foundation

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class InMemoryCache<Element: Cachable>: Cache<Element> {
	struct CachedItem {
		let cachedAt: Date
		let item: Element
	}
	
	var cache: [String: CachedItem] = [:]
	
	public override init(backingCache: Cache<Element>? = nil) {
		super.init(backingCache: backingCache)
        #if os(iOS)
            self.addAsObserver(of: UIApplication.didReceiveMemoryWarningNotification, selector: #selector(didReceiveMemoryWarningNotification))
        #endif
	}
	
	@objc func didReceiveMemoryWarningNotification() {
		clearCache()
	}
	
	public override func clearCache() { self.cache = [:] }
	
	public override func fetch(for url: URL, behavior: CacheBehavior = .normal) -> AnyPublisher<Element, Error> {
		let cacheKey = key(for: url)
		
		if let current = cache[cacheKey], !behavior.shouldIgnoreLocal(forDate: current.cachedAt) { return self.just(current.item) }
		return super.fetch(for: url, behavior: behavior)
			.flatMap { result -> AnyPublisher<Element, Error> in
				self.store(result, for: url)
				return self.just(result)
			}
			.eraseToAnyPublisher()
	}
	
	public override func clear(itemFor url: URL) {
		let cacheKey = key(for: url)
		cache.removeValue(forKey: cacheKey)
	}

	public override func store(_ element: Element, for url: URL) {
		let cacheKey = key(for: url)
		cache[cacheKey] = CachedItem(cachedAt: Date(), item: element)
		super.store(element, for: url)
	}
	
	func key(for url: URL) -> String { url.absoluteString.sha256 }
}

#endif
