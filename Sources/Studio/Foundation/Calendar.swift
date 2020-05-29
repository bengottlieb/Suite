//
//  Calendar.swift
//  
//
//  Created by Ben Gottlieb on 5/28/20.
//

import Foundation


public extension Calendar {
	static func with(timeZone: TimeZone?) -> Calendar {
		var calendar = Calendar.current
		calendar.timeZone = timeZone ?? .current
		return calendar
	}
	
	func firstDayInMonth(_ date: Date) -> Date {
		var components = self.dateComponents([.month, .year], from: date)
		components.day = 1
		components.second = 0
		components.minute = 0
		components.hour = 0
		return self.date(from: components) ?? date
	}
}

public extension TimeZone {
	static var gmt: TimeZone { TimeZone(identifier: "GMT") ?? TimeZone(secondsFromGMT: 0)! }
}
