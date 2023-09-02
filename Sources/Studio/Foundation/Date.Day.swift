//
//  Date.Day.swift
//  
//
//  Created by Ben Gottlieb on 4/10/23.
//

import Foundation

public extension Date {
	struct Day: Codable, CustomStringConvertible {
		public var day: Int
		public var month: Foundation.Date.Month
		public var year: Int
		
		public var description: String {
			
			if #available(iOS 15.0, macOS 12, watchOS 8, *) {
				return date.formatted(date: .numeric, time: .omitted)
			} else {
				return "\(month.rawValue)/\(day)/\(year)"
			}
		}
		
		public init?(mdy: String) {
			guard let components = mdy.dateComponents else { return nil }
			
			self.init(day: components[1], month: components[0], year: components[2])
		}
		
		public init?(dmy: String) {
			guard let components = dmy.dateComponents else { return nil }
			
			self.init(day: components[0], month: components[1], year: components[2])
		}
		
		public init(day: Int, month: Month, year: Int) {
			self.day = day
			self.month = month
			self.year = year
		}

		public init?(day: Int, month: Int, year: Int) {
			guard let actualMonth = Month(rawValue: month) else { return nil }
			self.day = day
			self.month = actualMonth
			self.year = year < 1000 ? year + 2000 : year
		}
		
		public var date: Date {
			Date(calendar: .current, timeZone: .current, year: year, month: month.rawValue, day: day) ?? Date()
		}
		
		public var dmyString: String { "\(day)/\(month.rawValue)/\(year)" }
	}
	
	var day: Day {
		Day(day: dayOfMonth, month: month, year: year)
	}
	
	init(_ date: Date.Day, _ time: Date.Time?) {
		self = Date(calendar: .current, timeZone: .current, year: date.year, month: date.month.rawValue, day: date.day, hour: time?.isNever == false ? time?.hour : nil, minute: time?.isNever == false ? time?.minute : nil) ?? Date()
	}
}

extension String {
	fileprivate var dateComponents: [Int]? {
		var comp = self.components(separatedBy: "/")
		if comp.count < 3 { comp = self.components(separatedBy: "/") }
		if comp.count < 3 { return nil }
		
		let ints = comp.compactMap { Int($0) }
		if ints.count < 3 { return nil }
		
		return ints.first(3)
	}
}
