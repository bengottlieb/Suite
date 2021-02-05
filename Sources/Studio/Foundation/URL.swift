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
	init(_ string: StaticString) {
		self = URL(string: "\(string)")!
	}
	
    var filename: String { deletingPathExtension().lastPathComponent }

	var relativePathToHome: String? {
		return self.path.abbreviatingWithTildeInPath
	}

	static let blank: URL = URL(string: "about:blank")!
	
	init(withPathRelativeToHome path: String) {
		self.init(fileURLWithPath: path.expandingTildeInPath)
	}
	
	var existsOnDisk: Bool {
		if !self.isFileURL { return false }
		
		return FileManager.default.fileExists(at: self)
	}
	
	var queryDictionary: [String: String] {
		let pairs = self.query?.components(separatedBy: "&") ?? []
		var dict: [String: String] = [:]
		
		for keyPair in pairs {
			let split = keyPair.components(separatedBy: "=")
			guard split.count == 2 else { continue }
			dict[split[0]] = split[1]
		}
		return dict
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
            print("Unable to extract secore data: \(error)")
            return nil
        }
    }
}
#endif
