//
//  ImageCache.swift
//  Internal
//
//  Created by Ben Gottlieb on 1/6/21.
//

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public protocol Cachable {
	var cacheableData: Data? { get }
	var cacheCost: UInt64 { get }
	init?(data: Data)
}

#if canImport(UIKit)
import UIKit
@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension UIImage: Cachable {
    public var cacheableData: Data? { self.pngData() }
    public var cacheCost: UInt64 { UInt64(size.width * size.height) }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class ImageCache: Cache<UIImage> {
    public static var root = FileManager.cachesDirectory.appendingPathComponent("cached-images")
    public static let instance = InMemoryCache<UIImage>(backingCache: DiskCache<UIImage>(backingCache: RemoteCache<UIImage>(), rootedAt: ImageCache.root, pathExtension: "png"))
}
#endif

#if canImport(AppKit)
import AppKit
@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension NSImage: Cachable {
    public var cacheableData: Data? {
        guard let rep = tiffRepresentation else { return nil }
        let bmp = NSBitmapImageRep(data: rep)
        return bmp?.representation(using: .png, properties: [:])
    }
    public var cacheCost: UInt64 { UInt64(size.width * size.height) }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class ImageCache: Cache<NSImage> {
    public static var root = FileManager.cachesDirectory.appendingPathComponent("cached-images")
    public static let instance = InMemoryCache<NSImage>(backingCache: DiskCache<NSImage>(backingCache: RemoteCache<NSImage>(), rootedAt: ImageCache.root, pathExtension: "png"))
}
#endif

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension Data: Cachable {
	public var cacheableData: Data? { self }
	public var cacheCost: UInt64 { UInt64(count) }
	public init?(data: Data) {
		self = data
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class DataCache: Cache<Data> {
	public static var root = FileManager.cachesDirectory.appendingPathComponent("cached-data")
	public static let instance = InMemoryCache<Data>(backingCache: DiskCache<Data>(backingCache: RemoteCache<Data>(), rootedAt: DataCache.root, pathExtension: "dat"))
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class Cache<Element: Cachable>: NSObject {
	public enum CacheError: Error { case notFound, noLocalItemFound, failedToUnCache }
	public enum CacheBehavior: Equatable { case normal, alwaysReturnLocal, returnLocalIfNewerThan(Date), ignoreLocal, ignoreRemote
		func shouldIgnoreLocal(forDate: Date?) -> Bool {
			switch self {
			case .normal: return false
			case .alwaysReturnLocal: return false
			case .returnLocalIfNewerThan(let limit):
				guard let date = forDate else { return true }
				return date > limit
			case .ignoreLocal: return true
			case .ignoreRemote: return false
			}
		}
		
		public static func ==(lhs: CacheBehavior, rhs: CacheBehavior) -> Bool {
			switch (lhs, rhs) {
			case (.normal, .normal), (.alwaysReturnLocal, .alwaysReturnLocal), (.ignoreLocal, .ignoreLocal), (.ignoreRemote, .ignoreRemote): return true
			case (.returnLocalIfNewerThan(let date1), .returnLocalIfNewerThan(let date2)): return date1 == date2
			default: return false
			}
		}
		
		
	}
	
	public init(backingCache: Cache<Element>? = nil) {
		self.backingCache = backingCache
		super.init()
	}
	public func fetch(for url: URL, behavior: CacheBehavior = .normal) -> AnyPublisher<Element, Error> {
		if let backing = backingCache { return backing.fetch(for: url, behavior: behavior) }
		return .fail(with: CacheError.notFound)
	}

	public func store(_ element: Element, for url: URL) {
		backingCache?.store(element, for: url)
	}
	public func clear(itemFor url: URL) { backingCache?.clear(itemFor: url) }
	
	func just(_ result: Element) -> AnyPublisher<Element, Error> {
		Just(result)
			.mapError { _ in NSError() }
			.eraseToAnyPublisher()
	}
	
	public func clearCache() { }
	var backingCache: Cache<Element>?
}


#endif
