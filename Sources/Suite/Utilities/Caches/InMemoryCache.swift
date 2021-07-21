//
//  InMemoryCache.swift
//  
//
//  Created by ben on 1/7/21.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class InMemoryCache<Element: Cachable>: Cache<Element> {
    let queue = DispatchQueue(label: "_imMemoryCache_\(Element.self)", qos: .userInitiated, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    
    @discardableResult
    private func serialize(_ block: () -> Element?) -> Element? { queue.sync { block() } }
    
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
	
	public override func fetch(for url: URL, caching: CachePolicy = .normal) -> AnyPublisher<Element, Error> {
		let cacheKey = key(for: url)
		
        if let result = serialize({ if let current = cache[cacheKey], !caching.shouldIgnoreLocal(forDate: current.cachedAt) { return current.item }; return nil }) { return self.just(result) }
        
		return super.fetch(for: url, caching: caching)
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
        serialize {
            storeInCache(element, for: url)
            return nil
        }
	}
    
    private func storeInCache(_ element: Element, for url: URL) {
        let cacheKey = key(for: url)
        cache[cacheKey] = CachedItem(cachedAt: Date(), item: element)
        super.store(element, for: url)
    }
	
	public override func cachedValue(for url: URL) -> Element? {
        let key = self.key(for: url)
        return serialize {
            if let item = self.cache[key]?.item { return item }
            
            if let cached = super.cachedValue(for: url) {
                storeInCache(cached, for: url)
                return cached
            }
            return nil
        }
	}

	public override func hasCachedValue(for url: URL) -> Bool {
		let key = self.key(for: url)
		
        if serialize({ self.cache[key]?.item }) != nil { return true }
		return super.hasCachedValue(for: url)
	}

	func key(for url: URL) -> String { url.normalizedString.sha256 }
}

#endif
