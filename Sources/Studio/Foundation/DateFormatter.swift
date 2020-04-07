//
//  DateFormatter.swift
//  
//
//  Created by Ben Gottlieb on 12/2/19.
//

import Foundation

public extension DateFormatter {
	static let iso8601 = DateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss'Z'")
	
	convenience init(format: String) {
		self.init()
		self.dateFormat = format
		self.locale = Locale(identifier: "en_US_POSIX")
	}
}
