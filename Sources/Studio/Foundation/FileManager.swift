//
//  MobileProvisionFile.swift
//  Suite
//
//  Created by Ben Gottlieb on 9/9/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import Foundation

public extension FileManager {
	func fileExists(at url: URL?) -> Bool {
		guard let url = url else { return false }
		return self.fileExists(atPath: url.path)
	}
	
	func fileSize(at url: URL?) -> Int64 {
		guard let url = url, url.isFileURL else { return 0 }
		let attr = (try? attributesOfItem(atPath: url.path)) ?? [:]
		
		return attr[.size] as? Int64 ?? 0
	}
	
	func copy(itemsAt source: URL, into destination: URL, replacingOld: Bool = true, ignoringErrors: Bool = false) throws {
		do {
			try? createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
			let contents = try contentsOfDirectory(at: source, includingPropertiesForKeys: nil, options: [])
			
			for url in contents {
				let destURL = destination.appendingPathComponent(url.lastPathComponent)
				
				do {
					if directoryExists(at: url) {
						try copy(itemsAt: url, into: destURL, replacingOld: replacingOld)
					} else {
						if replacingOld, fileExists(at: destURL) { try? removeItem(at: destURL) }
						try copyItem(at: url, to: destURL)
					}
				} catch {
					if !ignoringErrors { throw error }
				}
			}
		} catch {
			if !ignoringErrors { throw error }
		}
	}
	
	func directoryExists(at url: URL) -> Bool {
		var isDir: ObjCBool = false
		
		if !self.fileExists(atPath: url.path, isDirectory: &isDir) { return false }
		
		return isDir.boolValue
	}

	func uniqueURL(in directory: URL, base: String) -> URL {
		var count = 0
		var name = base
		
		while true {
			let url = directory.appendingPathComponent(name)
			if !fileExists(at: url) { return url }
			count += 1
			if count == 1 {
				name = base
			} else {
				name = base + " \(count)"
			}
		}
	}
	
	func fileNotDirectoryExists(at url: URL) -> Bool {
		var isDir: ObjCBool = false
		
		if !self.fileExists(atPath: url.path, isDirectory: &isDir) { return false }
		
		return !isDir.boolValue
	}
	
	static func randomFileName(extension ext: String = "dat") -> String {
		return "\(UUID().uuidString).\(ext)"
	}
	
	static func tempFileURL(extension ext: String = "dat") -> URL {
		let name = self.randomFileName(extension: ext)
		
		return self.tempDirectory.appendingPathComponent(name)
	}

	static var documentsDirectory: URL { .documents }
	static var applicationSupportDirectory: URL { .applicationSupport }
	static var libraryDirectory: URL { .library }
	static var cachesDirectory: URL { .caches }
	static var applicationSpecificSupportDirectory: URL { .applicationSpecificSupport }
	static var tempDirectory: URL { return .temp }
	
	static var realHomeDirectory: URL {
		#if os(OSX)
			let home = FileManager.default.homeDirectoryForCurrentUser
			let components = home.path.components(separatedBy: "/")
			
			if let index = components.firstIndex(of: "Containers"), index > 2 {
				return URL(fileURLWithPath: components[0..<(index - 1)].joined(separator: "/"))
			}
			
			return home
        #else
            return self.documentsDirectory.deletingLastPathComponent()
		#endif
	}

	static func documentURL(at path: String) -> URL { .document(named: path) }
	static func cacheURL(at path: String) -> URL { .cache(named: path) }
	static func libraryURL(at path: String) -> URL { .library(named: path) }
}
