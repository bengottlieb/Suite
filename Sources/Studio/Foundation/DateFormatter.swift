//
//  DateFormatter.swift
//  
//
//  Created by Ben Gottlieb on 12/2/19.
//

import Foundation

public extension DateFormatter {
//	static let iso8601 = DateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss'Z'")
	
	static let iso8601: DateFormatter = {
		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
		return formatter
	}()

	convenience init(format: String) {
		self.init()
		self.dateFormat = format
		self.locale = Locale(identifier: "en_US_POSIX")
	}
	
	static var defaultJSONFormatter = DateFormatter.iso8601
}
