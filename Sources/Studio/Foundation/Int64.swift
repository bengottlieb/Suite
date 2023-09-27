//
//  Int64.swift
//
//
//  Created by Ben Gottlieb on 8/28/23.
//

import Foundation

public extension Int64 {
	static var byteFormatter = ByteCountFormatter()
	
	var bytesString: String {
		Self.byteFormatter.string(fromByteCount: self)
	}
}


