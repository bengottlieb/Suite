//
//  ImageCache.swift
//  Internal
//
//  Created by Ben Gottlieb on 1/6/21.
//

import UIKit

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public protocol Cachable {
	var cacheableData: Data? { get }
	init?(data: Data)
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension UIImage: Cachable {
	public var cacheableData: Data? { self.pngData() }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class ImageCache: Cache<UIImage> {
	public static var root = FileManager.cachesDirectory.appendingPathComponent("images")
	public static let instance = InMemoryCache<UIImage>(backingCache: DiskCache<UIImage>(backingCache: WebCache<UIImage>(), rootedAt: ImageCache.root, pathExtension: "png"))
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class Cache<Element: Cachable> {
	public enum CacheError: Error { case notFound, failedToUnCache }
	
	init(backingCache: Cache<Element>? = nil) {
		self.backingCache = backingCache
	}
	func fetch(for url: URL) -> AnyPublisher<Element, Error> {
		if let backing = backingCache { return backing.fetch(for: url) }
		return .fail(with: CacheError.notFound)
	}

	func store(_ element: Element, for url: URL) {
		backingCache?.store(element, for: url)
	}
	func clear(itemFor url: URL) { backingCache?.clear(itemFor: url) }
	
	func just(_ result: Element) -> AnyPublisher<Element, Error> {
		Just(result)
			.mapError { _ in NSError() }
			.eraseToAnyPublisher()
	}
	
	var backingCache: Cache<Element>?
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class InMemoryCache<Element: Cachable>: Cache<Element> {
	var cache: [String: Element] = [:]
	
	public override func fetch(for url: URL) -> AnyPublisher<Element, Error> {
		let cacheKey = key(for: url)
		
		if let current = cache[cacheKey] { return self.just(current) }
		return super.fetch(for: url)
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
		cache[cacheKey] = element
	}
	
	func key(for url: URL) -> String { url.absoluteString.sha256 }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class DiskCache<Element: Cachable>: Cache<Element> {
	let root: URL
	let fileExtension: String
	
	public init(backingCache: Cache<Element>?, rootedAt: URL, pathExtension: String) {
		root = rootedAt
		fileExtension = pathExtension
		super.init(backingCache: backingCache)

		try? FileManager.default.createDirectory(at: rootedAt, withIntermediateDirectories: true, attributes: nil)
	}
	
	public override func fetch(for url: URL) -> AnyPublisher<Element, Error> {
		let file = location(for: url)
		
		if FileManager.default.fileExists(at: file) {
			do {
				let data = try Data(contentsOf: file)
				guard let result = Element(data: data) else { throw CacheError.failedToUnCache }
				return self.just(result)
			} catch {
				return Fail(outputType: Element.self, failure: error).eraseToAnyPublisher()
			}
		}

		return super.fetch(for: url)
	}
	
	func location(for url: URL) -> URL {
		let filename = url.absoluteString.sha256
		
		return root.appendingPathComponent(filename).appendingPathExtension(fileExtension)
	}
	
	public override func clear(itemFor url: URL) {
		let file = location(for: url)
		
		try? FileManager.default.removeItem(at: file)
	}

	
	public override func store(_ element: Element, for url: URL) {
		let file = location(for: url)
		
		try? FileManager.default.removeItem(at: file)
		guard let data = element.cacheableData else { return }			// nothing to store
		
		do {
			try data.write(to: file)
		} catch {
			logg(error: error, "Failed to store \(url) at \(file) in \(self)")
		}
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class WebCache<Element: Cachable>: Cache<Element> {
	let session: URLSession
	
	public init(session urlSession: URLSession = .shared) {
		session = urlSession
		super.init(backingCache: nil)
	}
	
	public override func fetch(for url: URL) -> AnyPublisher<Element, Error> {
		session.dataTaskPublisher(for: url)
			.tryMap { output in
				if let result = Element(data: output.data) { return result }
				throw CacheError.failedToUnCache
			}
			.eraseToAnyPublisher()
	}
}


#endif
