//
//  ProcessInfo.swift
//  
//
//  Created by Ben Gottlieb on 3/12/23.
//

import Foundation

public extension ProcessInfo {
	static func bool(for key: String) -> Bool {
		if let string = self.string(for: key)?.lowercased() {
			return string == "y" || string == "yes" || string == "true"
		}
		
		return false
	}

	static func int(for key: String) -> Int? {
		guard let raw = self.string(for: key) else { return nil }
		return Int(raw.numbersOnly)
	}

	static func uint64(for key: String) -> UInt64? {
		guard let raw = self.string(for: key) else { return nil }
		return UInt64(raw.numbersOnly)
	}

	static func string(for key: String) -> String? {
		processInfo.environment[key]
	}
}
