//
//  ImageCache.swift
//  Internal
//
//  Created by Ben Gottlieb on 1/6/21.
//

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public protocol CacheStorable {
	var cacheableData: Data? { get }
	var cacheCost: UInt64 { get }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public protocol CacheExtractable {
	static func create(with data: Data) -> Any?
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public typealias Cachable = CacheStorable & CacheExtractable

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension Encodable {
	public var cacheableData: Data? { try? self.asJSONData() }
	public var cacheCost: UInt64 { cacheableData?.cacheCost ?? 0 }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension Decodable {
	static func create(with data: Data) -> Any? { try? Self.loadJSON(data: data) }
}

#if canImport(UIKit)
import UIKit
@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension UIImage: Cachable {
	public var cacheableData: Data? { self.pngData() }
	public var cacheCost: UInt64 { UInt64(size.width * size.height) }
	public static func create(with data: Data) -> Any? { UIImage(data: data) }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class ImageCache: Cache<UIImage> {
	public static var remoteCache = RemoteCache<UIImage>() { didSet { ImageCache.instance.backingCache?.backingCache = remoteCache }}
	public static let diskCache = DiskCache<UIImage>(backingCache: ImageCache.remoteCache, rootedAt: ImageCache.root, pathExtension: "png")

	public static var root = FileManager.cachesDirectory.appendingPathComponent("cached-images") { didSet { diskCache.root = root }}
	public static let instance = InMemoryCache<UIImage>(backingCache: diskCache)
}
#elseif canImport(AppKit)
import AppKit
@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension NSImage: Cachable {
	public static func create(with data: Data) -> Any? { NSImage(data: data) }
	public var cacheableData: Data? {
		guard let rep = tiffRepresentation else { return nil }
		let bmp = NSBitmapImageRep(data: rep)
		return bmp?.representation(using: .png, properties: [:])
	}
	public var cacheCost: UInt64 { UInt64(size.width * size.height) }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class ImageCache: Cache<NSImage> {
	public static var remoteCache = RemoteCache<NSImage>() { didSet { ImageCache.instance.backingCache?.backingCache = remoteCache }}
	public static let diskCache = DiskCache<NSImage>(backingCache: ImageCache.remoteCache, rootedAt: ImageCache.root, pathExtension: "png")

	public static var root = FileManager.cachesDirectory.appendingPathComponent("cached-images") { didSet { diskCache.root = root }}
	public static let instance = InMemoryCache<NSImage>(backingCache: diskCache)
}
#endif

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension Data: Cachable {
	public var cacheableData: Data? { self }
	public var cacheCost: UInt64 { UInt64(count) }
	public static func create(with data: Data) -> Any? { data }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class DataCache: Cache<Data> {
	public static var remoteCache = RemoteCache<Data>() { didSet { DataCache.instance.backingCache?.backingCache = remoteCache }}
	public static let diskCache = DiskCache<Data>(backingCache: DataCache.remoteCache, rootedAt: DataCache.root, pathExtension: "dat")

	public static var root = FileManager.cachesDirectory.appendingPathComponent("cached-data") { didSet { diskCache.root = root }}
	public static let instance = InMemoryCache<Data>(backingCache: diskCache)
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public enum CacheError: Error, LocalizedError { case noURL, notFound(URL), unknownResponse(URL?), noLocalItemFound(URL), failedToDecode(URL, URL, Error), failedToUnCache(URL), failedToUnCacheFromDisk(URL), failedToDownload(URL, Data), failedToDownloadServerError(URL, Error)
	public var errorDescription: String? {
		switch self {
        case CacheError.noURL: return "no URL provided"
        case CacheError.notFound(let url): return "Item not found: \(url.absoluteString)"
        case CacheError.unknownResponse(let url): return "Unknown response from \(url?.absoluteString ?? "the server")"
		case CacheError.noLocalItemFound(let url): return "Local item not found: \(url.absoluteString)"
		case CacheError.failedToUnCache(let url): return "Item not found: \(url.absoluteString)"
		case CacheError.failedToDecode(let src, let local, let error): return "Failed to decode from \(local.path) (original location: \(src.absoluteString)): \(error)"
		case CacheError.failedToUnCacheFromDisk(let url): return "Item not found: \(url.absoluteString)"
		case CacheError.failedToDownload(let url, let data):
			return "Item failed to download: \(url.absoluteString) (got: \(String(data: data, encoding: .utf8) ?? "nothing"))"
        case CacheError.failedToDownloadServerError(let url, let error): return "\(url.absoluteString) failed: \(error.localizedDescription)"
		}
	}
}
public extension URLRequest.CachePolicy {
	static let `default` = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
	func shouldIgnoreLocal(forDate: Date?) -> Bool {
		switch self {
		case .useProtocolCachePolicy: return false
		case .reloadIgnoringLocalCacheData: return true
		case .reloadIgnoringLocalAndRemoteCacheData: return true
		case .returnCacheDataElseLoad: return false
		case .returnCacheDataDontLoad: return false
		case .reloadRevalidatingCacheData: return false
		@unknown default: return false
		}
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class Cache<Element: Cachable>: NSObject {
	public init(backingCache: Cache<Element>? = nil) {
		self.backingCache = backingCache
		super.init()
	}
	public func fetch(for url: URL, caching: URLRequest.CachePolicy = .default) -> AnyPublisher<Element, Error> {
		if let backing = backingCache { return backing.fetch(for: url, caching: caching) }
		return .fail(with: CacheError.notFound(url))
	}
	
	public func store(_ element: Element, for url: URL) {
		backingCache?.store(element, for: url)
	}
	
	public func cachedValue(for url: URL, newerThan date: Date?) -> Element? { backingCache?.cachedValue(for: url, newerThan: date) }
	public func hasCachedValue(for url: URL, newerThan date: Date?) -> Bool { backingCache?.hasCachedValue(for: url, newerThan: date) ?? false }
	
	public func clear(itemFor url: URL) { backingCache?.clear(itemFor: url) }
	
	func just(_ result: Element) -> AnyPublisher<Element, Error> {
		Just(result)
			.mapError { _ in NSError() }
			.eraseToAnyPublisher()
	}
	
	public func clearCache() { }
	var backingCache: Cache<Element>?
	
	public func fetch(for url: URL, caching: URLRequest.CachePolicy = .default) async throws -> Element {
		if let backing = backingCache {
			let result = try await backing.fetch(for: url, caching: caching)
			store(result, for: url)
			return result
		}
		throw CacheError.notFound(url)
	}
}


#endif
