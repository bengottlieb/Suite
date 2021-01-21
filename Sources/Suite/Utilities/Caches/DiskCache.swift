//
//  DiskCache.swift
//  
//
//  Created by ben on 1/7/21.
//

import Foundation

#if canImport(Combine)

import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class DiskCache<Element: Cachable>: Cache<Element> {
	let root: URL
	let fileExtension: String
	
	struct CachedItemInfo {
		let url: URL
		let cachedAt: Date
	}
	
	public init(backingCache: Cache<Element>?, rootedAt: URL, pathExtension: String) {
		root = rootedAt
		fileExtension = pathExtension
		super.init(backingCache: backingCache)

		try? FileManager.default.createDirectory(at: rootedAt, withIntermediateDirectories: true, attributes: nil)
	}
	
	public override func fetch(for url: URL, behavior: CachePolicy = .normal) -> AnyPublisher<Element, Error> {
		if url.isFileURL {
			do {
				let data = try Data(contentsOf: url)
				guard let result = Element.create(with: data) as? Element else {
					return Fail(outputType: Element.self, failure: CacheError.failedToUnCache).eraseToAnyPublisher()
				}
				return self.just(result)
			} catch {
				return Fail(outputType: Element.self, failure: error).eraseToAnyPublisher()
			}
		}
		
		let file = location(for: url)
		
		if let info = cacheInfo(for: url), !behavior.shouldIgnoreLocal(forDate: info.cachedAt) {
			do {
				let data = try Data(contentsOf: file)
				guard let result = Element.create(with: data) as? Element else { throw CacheError.failedToUnCache }
				return self.just(result)
			} catch {
				return Fail(outputType: Element.self, failure: error).eraseToAnyPublisher()
			}
		}

		return super.fetch(for: url, behavior: behavior)
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

	public override func localValue(for url: URL) -> Element? {
		let file = location(for: url)
		
		if FileManager.default.fileExists(at: file), let data = try? Data(contentsOf: file), let item = Element.create(with: data) as? Element {
			return item
		}
		return super.localValue(for: url)
	}

	public override func store(_ element: Element, for url: URL) {
		let file = location(for: url)
		
		if FileManager.default.fileExists(at: file) { return }
		guard let data = element.cacheableData else { return }			// nothing to store
		
		do {
			try data.write(to: file)
		} catch {
			logg(error: error, "Failed to store \(url) at \(file) in \(self)")
		}
		super.store(element, for: url)
	}
}

#endif
