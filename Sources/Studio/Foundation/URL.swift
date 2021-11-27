//
//  URL.swift
//  
//
//  Created by Ben Gottlieb on 12/30/19.
//

import Foundation

public protocol URLLocatable {
	var url: URL { get }
}

extension URL: Identifiable {
	public var id: String { self.absoluteString }
}

extension URL: ExpressibleByStringLiteral {
	public init(stringLiteral value: StringLiteralType) {
		self.init(string: value)!
	}
}

public extension URL {
	static func +(lhs: URL, rhs: String) -> URL {
		lhs.appendingPathComponent(rhs)
	}
	
	func dropLast() -> URL {
		deletingLastPathComponent()
	}

	var isAppStoreURL: Bool {
		host?.contains("apps.apple.com") == true
	}

	var existingDirectory: URL? {
		if !isFileURL { return nil }
		
		if FileManager.default.directoryExists(at: self) { return self }
		
		do {
			try FileManager.default.createDirectory(at: self, withIntermediateDirectories: true, attributes: nil)
			return self
		} catch {
			Studio.logg(error: error, "Unable to create directory at \(path)")
			return nil
		}
	}
	
	init?(_ string: String, _ query: [String: String]) {
		guard var base = URL(string: string) else { return nil }
		
		base.queryDictionary = query
		self = base
	}

	init(_ string: StaticString) {
		self = URL(string: "\(string)")!
	}
	
    var filename: String { deletingPathExtension().lastPathComponent }

	var relativePathToHome: String? {
		return self.path.abbreviatingWithTildeInPath
	}

	var isInBundle: Bool { scheme == "bundle" }

	static let blank: URL = URL(string: "about:blank")!
	
	init(withPathRelativeToHome path: String) {
		self.init(fileURLWithPath: path.expandingTildeInPath)
	}
	
	var existsOnDisk: Bool {
		if !self.isFileURL { return false }
		
		return FileManager.default.fileExists(at: self)
	}

    subscript(name: String) -> String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        
        return components.queryItems?.first { $0.name == name }?.value
    }
	
	var queryDictionary: [String: String] {
		get {
			guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return [:] }
			var pairs: [String: String] = [:]
			
			for item in components.queryItems ?? [] {
				pairs[item.name] = item.value
			}
			return pairs
		}
		
		set {
			guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return }
			
			components.queryItems = newValue.keys.map { URLQueryItem(name: $0, value: newValue[$0]) }
			if let newURL = components.url {
				self = newURL
			}
		}
	}
	
	var fileSize: UInt64 { FileManager.default.fileSize(at: self) }
	
	func replacingPathExtension(with ext: String) -> URL {
		deletingPathExtension().appendingPathExtension(ext)
	}
	
	var fileAttributes: [FileAttributeKey : Any]? {
		guard self.isFileURL else { return nil }
		return (try? FileManager.default.attributesOfItem(atPath: path)) ?? [:]
	}
	
	var createdAt: Date? {
		fileAttributes?[.creationDate] as? Date
	}

	var modifiedAt: Date? {
		fileAttributes?[.modificationDate] as? Date
	}
	
	var normalizedString: String {
		guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return absoluteString }
		
		let queryItems = components.queryItems?.sorted() ?? []
		let queryString = queryItems.map { $0.name + "=" + $0.value }.joined(separator: "&")
		let scheme = components.scheme ?? "https"
		let host = components.host ?? "sample.com"
		let path = components.path
		
		var result = scheme + "://" + host
		if let port = components.port { result += ":\(port)" }
		result += path
		if queryItems.isNotEmpty { result += "?" + queryString }
		
		return result
	}
}

extension URLQueryItem: Comparable {
	public static func <(lhs: URLQueryItem, rhs: URLQueryItem) -> Bool {
		lhs.name < rhs.name
	}
}

#if os(OSX)
public extension URL {
    @discardableResult
    func accessSecurely(block: () -> Void) -> Bool {
        if !hasValidBookmarkData || !startAccessingSecurityScopedResource() { return false }
        block()
        stopAccessingSecurityScopedResource()
        return true
    }
    init?(secureBookmarkData data: Data?) {
        var stale = false
        guard let data = data else {
            self.init(string: "")
            return nil
        }
        do {
            self = try URL(resolvingBookmarkData: data, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &stale)
            
            if stale { return nil }
        } catch {
            return nil
        }
    }
    
    var hasValidBookmarkData: Bool {
        guard let data = secureBookmarkData else { return false }
        
        return URL(secureBookmarkData: data) != nil
    }
    
    var secureBookmarkData: Data? {
        do {
            return try self.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
        } catch {
            Studio.logg(error: error, "Unable to extract secure data: \(error)")
            return nil
        }
    }
}
#endif

public extension Array where Element == URL {
	func sortedChronologically(oldestFirst: Bool = false) -> [Element] {
		self.sorted {
			guard let d1 = $0.createdAt else { return oldestFirst }
			guard let d2 = $1.createdAt else { return !oldestFirst }
			
			if oldestFirst { return d1 < d2 }
			return d1 > d2
		}
	}
}
