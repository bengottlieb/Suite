//
//  VersionString.swift
//  
//
//  Created by Ben Gottlieb on 9/24/21.
//

import Foundation

public struct VersionString: Comparable {
	let string: String
	
	var components: [Int] {
		string.components(separatedBy: ".").compactMap { Int($0) }
	}
	
	public static func ==(lhs: VersionString, rhs: VersionString) -> Bool {
		lhs.components == rhs.components
	}

	public static func <(lhs: VersionString, rhs: VersionString) -> Bool {
		let lComponents = lhs.components
		let rComponents = rhs.components
		
		for i in 0..<(max(lComponents.count, rComponents.count)) {
			let left = i < lComponents.count ? lComponents[i] : 0
			let right = i < rComponents.count ? rComponents[i] : 0
			
			if left < right { return true }
			if left > right { return false }
		}
		
		return false
	}

	public init(_ string: String) {
		self.string = string
	}
}
