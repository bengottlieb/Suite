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
            
            for hour in (hour + 1)...(end.hour) {
                times.append(Date.Time(hour: hour, minute: 0))
            }
            
            return times
        }
		
		public func byAdding(hours: Int = 0, minutes: Int = 0, seconds: TimeInterval = 0) -> Time {
			var second = self.second + seconds
			var minute = self.minute + minutes
			var hour = (self.hour + hours + 24) % 24
			
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
		
		public func timeInterval(since other: Date.Time) -> TimeInterval {
			if self == other { return 0 }
			let otherSeconds = other.timeInterval
			let mySeconds = self.timeInterval
			
			if otherSeconds <= mySeconds {
				return mySeconds - otherSeconds
			}
			
			return Time.lastSecond.timeInterval(since: other) + self.timeInterval(since: .midnight)
		}
		
		init(timeInterval: TimeInterval) {
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
			date.localTimeString(date: .none, time: .abbr)
		}
	}

	var time: Time {
		let components = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: self)
		return Time(hour: components.hour ?? 0, minute: components.minute ?? 0, second: TimeInterval(components.second ?? 0) + min(1, TimeInterval(components.nanosecond ?? 0) / 1_000_000_000))
	}
}

extension Array where Element == Date.Time {
	public func average() -> Date.Time? {
		guard !isEmpty else { return nil }
		let sum = self.map { $0.timeInterval }.sum()
		
		return Date.Time(timeInterval: sum / TimeInterval(count))
	}
}
