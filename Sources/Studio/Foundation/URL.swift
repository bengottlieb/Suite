//
//  URL.swift
//  
//
//  Created by Ben Gottlieb on 12/30/19.
//

import Foundation

extension URL: Identifiable {
	public var id: String { self.absoluteString }
}

public extension URL {
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
}
