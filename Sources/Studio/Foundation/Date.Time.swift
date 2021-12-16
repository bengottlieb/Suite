//
//  Date.Time.swift
//  
//
//  Created by Ben Gottlieb on 2/12/21.
//

import Foundation

#if canImport(SwiftUI)
extension Date.Time: Identifiable {
    public var id: TimeInterval { timeInterval }
}
#endif

public extension Date {
	init?(time: Time?) {
		guard let time = time else { return nil }
		self.init(calendar: Calendar.current, hour: time.hour, minute: time.minute, second: Int(time.second), nanosecond: 0)
	}

	func allHours(until end: Date) -> [Date] {
		var date = self
		
		if self.minute == 0 {
			date = self.nearestSecond
		} else {
			date = self.nearestHour.byAdding(hours: 1)
		}
		
		let count = Calendar.current.dateComponents([.hour], from: self, to: end).hour ?? 1
		return (0..<count).map { date.addingTimeInterval(TimeInterval($0) * .hour)}
	}
	
	struct TimeRange {
		public var start: Date.Time
		public var end: Date.Time
		
		public init(_ start: Date.Time, _ end: Date.Time) {
			self.start = start
			self.end = end
		}

		public var duration: TimeInterval {
			if start < end {
				return end.timeInterval - start.timeInterval
			}
			
			return (Date.Time.lastSecond.timeInterval - start.timeInterval) + (end.timeInterval)
		}
	}

	struct Time: Codable, Comparable, Equatable, CustomStringConvertible {
		public let hour: Int
		public let minute: Int
		public let second: TimeInterval
		
		public static let midnight = Date.Time(hour: 0, minute: 0, second: 0)
		public static let lastSecond = Date.Time(hour: 23, minute: 59, second: 59 )

		public var timeInterval: TimeInterval {
			TimeInterval(hour * 3600) + TimeInterval(minute * 60) + second
		}
		
		public static func <(lhs: Time, rhs: Time) -> Bool {
			lhs.timeInterval < rhs.timeInterval
		}
		
		public static func ==(lhs: Time, rhs: Time) -> Bool {
			lhs.timeInterval == rhs.timeInterval
		}

		public func allHours(until end: Date.Time) -> [Date.Time] {
			var times: [Date.Time] = []
			
			if minute == 0 {
				times.append(Date.Time(hour: hour, minute: 0))
			}
			
			let end = end.hour <= hour ? end.hour + 12 : end.hour
			for hour in (hour + 1)...(end) {
				times.append(Date.Time(hour: hour % 24, minute: 0))
			}
			
			return times
		}
		
		public func byAdding(hours: Int = 0, minutes: Int = 0, seconds: TimeInterval = 0) -> Time {
			var second = self.second + TimeInterval(Int(seconds) % 60)
			var minute = self.minute + minutes + Int(seconds / 60) % 60
			var hour = (self.hour + hours + 24 + Int(seconds / 3600)) % 24
			
			if second < 0 {
				minute -= 1
				second += 60
			} else if second > 60 {
				minute += 1
				second -= 60
			}

			if minute < 0 {
				hour -= 1
				minute += 60
			} else if minute > 60 {
				hour += 1
				minute -= 60
			}
			return Time(hour: hour, minute: minute, second: second)
		}
		
		public static func -(lhs: Time, rhs: Time) -> Time {
			lhs.byAdding(hours: -rhs.hour, minutes: -rhs.minute, seconds: -rhs.second)
		}
		
		public init(hour: Int, minute: Int, second: TimeInterval = 0) {
			self.hour = min(hour, 23)
			self.minute = min(minute, 59)
			self.second = min(second, 59)
		}
		
		public var description: String {
			if second == 0 {
				return String(format: "%d:%02d", hour, minute)
			} else {
				return String(format: "%d:%02d:%02d", hour, minute, Int(second))
			}
		}
		
		public var timeIntervalSinceNow: TimeInterval {
			timeInterval(since: Date().time)
		}
		
		public func timeInterval(since other: Date.Time) -> TimeInterval {
			if self == other { return 0 }
			let otherSeconds = other.timeInterval
			let mySeconds = self.timeInterval
			
			if otherSeconds <= mySeconds {
				return mySeconds - otherSeconds
			}
			
			return Time.lastSecond.timeInterval(since: other) + self.timeInterval(since: .midnight)
		}
		
		public init(timeInterval: TimeInterval) {
			hour = Int(timeInterval / 3600) % 24
			minute = Int(timeInterval / 60) % 60
			second = TimeInterval(Int(timeInterval) % 60)
		}
		
		public var nextHour: Time {
			Date.Time(hour: (hour + 1) % 24, minute: 0, second: 0)
		}
		
		public var topOfHour: Time {
			Date.Time(hour: hour, minute: 0, second: 0)
		}
		
		public struct Frame {
			public let start: Time
			public let end: Time
			
			public init(_ start: Time, _ end: Time) {
				self.start = start
				self.end = end
			}
			
			public var duration: TimeInterval { end.timeInterval(since: start) }
		}
		
		public var date: Date {
			var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
			
			components.hour = hour
			components.minute = minute
			components.second = Int(second)
			
			
			return Calendar.current.date(from: components) ?? Date()
		}
		
		public var hourMinuteString: String {
			date.localTimeString(date: .none, time: .short)
		}

		public var hourString: String {
			DateFormatter(format: "h").string(from: date)
		}
	}

	var time: Time {
		get {
			let components = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: self)
			return Time(hour: components.hour ?? 0, minute: components.minute ?? 0, second: TimeInterval(components.second ?? 0) + min(1, TimeInterval(components.nanosecond ?? 0) / 1_000_000_000))
		}
		
		set {
			self = byChanging(second: Int(newValue.second), minute: newValue.minute, hour: newValue.hour)
		}
	}
}

extension Array where Element == Date.Time {
	public func average() -> Date.Time? {
		guard !isEmpty else { return nil }
		let sum = self.map { $0.timeInterval }.sum()
		
		return Date.Time(timeInterval: sum / TimeInterval(count))
	}
}
