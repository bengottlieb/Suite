//
//  StringInterpolation.swift
//  
//
//  Created by ben on 12/9/20.
//

import Foundation

// hat tip to https://www.hackingwithswift.com/plus/advanced-swift/advanced-string-interpolation-part-one

public extension String.StringInterpolation {
	mutating func appendInterpolation<T: Encodable & AnyObject>(_ value: T) {
		if let string = value.stringValue {
			appendLiteral(string)
		}
	}
	
}
