//
//  DiskCache.swift
//  
//
//  Created by ben on 1/7/21.
//

import Foundation

#if canImport(Combine)

import Combine

public var logDiskCacheStores = false

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class DiskCache<Element: Cachable>: Cache<Element> {
	var root: URL { didSet { self.checkForRootDirectory() }}
	let fileExtension: String
	
	struct CachedItemInfo {
		let url: URL
		let cachedAt: Date
	}
	
	public init(backingCache: Cache<Element>?, rootedAt: URL, pathExtension: String) {
		root = rootedAt
		fileExtension = pathExtension
		super.init(backingCache: backingCache)
	}
	
	func checkForRootDirectory() {
		let url = root
		
		if FileManager.default.directoryExists(at: url) { return }
		try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
	}
	
	public override func fetch(for url: URL, caching: CachePolicy = .normal) -> AnyPublisher<Element, Error> {
		if url.isFileURL {
			do {
				let data = try Data(contentsOf: url)
				guard let result = Element.create(with: data) as? Element else {
					return Fail(outputType: Element.self, failure: CacheError.failedToUnCacheFromDisk(url)).eraseToAnyPublisher()
				}
				return self.just(result)
			} catch {
				return Fail(outputType: Element.self, failure: error).eraseToAnyPublisher()
			}
		}
		
		let file = location(for: url)
		
		if let info = cacheInfo(for: url), !caching.shouldIgnoreLocal(forDate: info.cachedAt) {
			do {
				let data = try Data(contentsOf: file)
				guard let result = Element.create(with: data) as? Element else {
					return Fail(outputType: Element.self, failure: CacheError.failedToUnCache(url)).eraseToAnyPublisher()
				}
				return self.just(result)
			} catch {
				return Fail(outputType: Element.self, failure: CacheError.failedToDecode(url, file, error)).eraseToAnyPublisher()
			}
		}

		return super.fetch(for: url, caching: caching)
	}
	
	public override func clearCache() {
		try? FileManager.default.removeItem(at: root)
		try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true, attributes: nil)
	}
	
	func cacheInfo(for url: URL) -> CachedItemInfo? {
		let file = location(for: url)
		
		guard let createdAt = file.createdAt else { return nil }
		return CachedItemInfo(url: file, cachedAt: createdAt)
	}
	
	func location(for url: URL) -> URL {
		let filename = url.absoluteString.sha256
		
		return root.appendingPathComponent(filename).appendingPathExtension(fileExtension)
	}
	
	public override func clear(itemFor url: URL) {
		let file = location(for: url)
		
		try? FileManager.default.removeItem(at: file)
	}

	public override func cachedValue(for url: URL) -> Element? {
		let file = location(for: url)
		
		if FileManager.default.fileExists(at: file), let data = try? Data(contentsOf: file), let item = Element.create(with: data) as? Element {
			return item
		}
		return super.cachedValue(for: url)
	}

	public override func hasCachedValue(for url: URL) -> Bool {
		let file = location(for: url)
		
		if FileManager.default.fileExists(at: file) { return true }
		return super.hasCachedValue(for: url)
	}

	public override func store(_ element: Element, for url: URL) {
		checkForRootDirectory()
		let file = location(for: url)
		
		if FileManager.default.fileExists(at: file) { return }
		guard let data = element.cacheableData else { return }			// nothing to store
		
		if logDiskCacheStores { logg("Caching \(url) to \(file.path)") }
		do {
			try data.write(to: file)
		} catch {
			logg(error: error, "Failed to store \(url) at \(file) in \(self)")
		}
		super.store(element, for: url)
	}
}

#endif
