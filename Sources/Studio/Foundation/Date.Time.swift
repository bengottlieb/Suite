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
		let now = Date()
		self.init(calendar: .current, timeZone: .current, year: now.year, month: now.month.rawValue, day: now.dayOfMonth, hour: time.hour, minute: time.minute, second: Int(time.second), nanosecond: 0)
	}
	
	func bySetting(time: Date.Time) -> Date {
		self.byChanging(nanosecond: nil, second: Int(time.second), minute: time.minute, hour: time.hour, day: nil, month: nil, year: nil)
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
	
	func next(time: Date.Time) -> Date {
		let next = Date(time: time) ?? Date().previousDay
		if next < Date() {
			return next.nextDay
		}
		return next
	}
	
	struct TimeRange: Equatable, CustomStringConvertible, Codable, Hashable {
		public var start: Date.Time
		public var end: Date.Time
		
		public init(_ start: Date.Time, _ end: Date.Time) {
			self.start = start
			self.end = end
		}

		public init(start: Date.Time, duration: TimeInterval) {
			self.start = start
			self.end = start.byAdding(timeInterval: duration)
		}
		
		public func dateInterval(on date: Date) -> DateInterval {
			let start = date.bySetting(time: start)
			return DateInterval(start: start, duration: duration)
		}
		
		public func shortened(by interval: TimeInterval) -> TimeRange? {
			if interval > self.duration { return nil }
			return TimeRange(start: start, duration: duration - interval)
		}

		public var duration: TimeInterval {
			if start <= end {
				return end.timeInterval - start.timeInterval
			}
			
			return (Date.Time.lastSecond.timeInterval - start.timeInterval) + (end.timeInterval)
		}
		
		public static func ==(lhs: Self, rhs: Self) -> Bool {
			lhs.start == rhs.start && lhs.end == rhs.end
		}
		
		public func intersection(with time: TimeRange) -> TimeRange? {
			if end.timeInterval < time.start.timeInterval || start.timeInterval > time.end.timeInterval { return nil }
			
			let newStart = max(start.timeInterval, time.start.timeInterval)
			let newEnd = min(end.timeInterval, time.end.timeInterval)
			
			return TimeRange(.init(timeInterval: newStart), .init(timeInterval: newEnd))
		}
		
		public var description: String {
			if start == end { return "\(start)" }
			return "\(start) - \(end)"
		}

		public var abbreviatedDescription: String {
			if start == end { return "\(start.abbreviatedDescription)" }
			return "\(start.abbreviatedDescription) - \(end.abbreviatedDescription)"
		}

		public init(startMinute minutes: Int, duration: TimeInterval) {
			let startHour = minutes / 60
			let startMinute = minutes % 60
			
			let endHour = (minutes + Int(duration / 60)) / 60
			let endMinute = (minutes + Int(duration / 60)) % 60
			
			self.init(.init(hour: startHour, minute: startMinute), .init(hour: endHour, minute: endMinute))
		}
	}

	struct Time: Codable, Comparable, Equatable, CustomStringConvertible, Hashable {
		public var hour: Int
		public var minute: Int
		public var second: TimeInterval
		
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
		
		public func roundedToNearest(minute: Int) -> Date.Time {
			if (minute + self.minute) >= 60 { return Date.Time(hour: (hour + 1) % 24, minute: 0) }
			return Date.Time(hour: hour, minute: minute * Int(round(Double(self.minute) / Double(minute))))
		}

		public func byAdding(timeInterval: TimeInterval) -> Date.Time {
			let hours = timeInterval / .hour
			let minutes = (timeInterval - floor(hours) * .hour) / .minute
			let seconds = TimeInterval(Int(timeInterval) % 60)
			
			return byAdding(hours: Int(hours), minutes: Int(minutes), seconds: seconds)
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
		
		public init?(string: String) {
			let chunks = string.components(separatedBy: .whitespaces)
			guard let hourMinuteChunk = chunks.first else { return nil }
			let components = hourMinuteChunk.components(separatedBy: ":")
			guard components.count >= 2, let hour = Int(components[0]), let minute = Int(components[1]) else { return nil }
			
			if chunks.count > 1, chunks[1].lowercased() == "pm", hour < 12, hour != 0 {
				self.hour = hour + 12
			} else {
				self.hour = hour
			}
			
			self.minute = minute
			if components.count > 2, let sec = TimeInterval(components[2]) {
				self.second = sec
			} else {
				self.second = 0
			}
		}
		
		public var stringValue: String { description }
		
		public var description: String {
			if second == 0 {
				return String(format: "%d:%02d", visibleHour, minute)
			} else {
				return String(format: "%d:%02d:%02d", visibleHour, minute, Int(second))
			}
		}
		
		public var visibleHour: Int {
			if Date.isIn24HourTimeMode { return hour }
			if hour == 0 || hour == 12 { return 12 }
			return hour % 12
		}
		
		public var abbreviatedDescription: String {
			let suffix = Date.isIn24HourTimeMode ? "" : (hour < 12 ? "a" : "p")
			if minute == 0 { return "\(visibleHour)\(suffix)" }
			
			return String(format: "%d:%02d\(suffix)", visibleHour, minute)
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
			get {
				var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
				
				components.hour = hour
				components.minute = minute
				components.second = Int(second)
				
				return Calendar.current.date(from: components) ?? Date()
			}
			set {
				let components = Calendar.current.dateComponents([.hour, .minute, .second], from: newValue)
				hour = components.hour ?? 0
				minute = components.minute ?? 0
				second = Double(components.second ?? 0)
			}
		}
		
		public var hourMinuteString: String {
			date.localTimeString(date: .none, time: .short)
		}

		public var hourString: String {
			DateFormatter(format: "h").string(from: date)
		}
		
		public static let never = Date.Time(hour: -1, minute: -1)
		
		public var isNever: Bool { hour == -1 || minute == -1 }
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
