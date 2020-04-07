//
//  URL.swift
//  
//
//  Created by Ben Gottlieb on 12/30/19.
//

import Foundation

public extension URL {
	var relativePathToHome: String? {
		return self.path.abbreviatingWithTildeInPath
	}
	
	init(withPathRelativeToHome path: String) {
		self.init(fileURLWithPath: path.expandingTildeInPath)
	}
}
