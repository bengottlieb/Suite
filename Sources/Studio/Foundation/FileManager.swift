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
	
	func directoryExists(at url: URL) -> Bool {
		var isDir: ObjCBool = false
		
		if !self.fileExists(atPath: url.path, isDirectory: &isDir) { return false }
		
		return isDir.boolValue
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

	static func systemDirectoryURL(which: FileManager.SearchPathDirectory) -> URL? {
		guard let path = NSSearchPathForDirectoriesInDomains(which, [.userDomainMask], true).first else { return nil }
		return URL(fileURLWithPath: path)
	}
	
	static var documentsDirectory: URL { return self.systemDirectoryURL(which: .documentDirectory)! }
	static var applicationSupportDirectory: URL { return self.systemDirectoryURL(which: .applicationSupportDirectory)! }
	static var libraryDirectory: URL { return self.systemDirectoryURL(which: .libraryDirectory)! }
	static var cachesDirectory: URL { return self.systemDirectoryURL(which: .cachesDirectory)! }
	static var applicationSpecificSupportDirectory: URL { return self.systemDirectoryURL(which: .applicationSupportDirectory)!.appendingPathComponent(Bundle.main.bundleIdentifier ?? Bundle.main.name) }
	static var tempDirectory: URL { return URL(fileURLWithPath: NSTemporaryDirectory()) }
}
