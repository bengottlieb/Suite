//
//  TimeInterval.swift
//  
//
//  Created by Ben Gottlieb on 12/20/20.
//

import Foundation

public extension TimeInterval {
	static let minute: TimeInterval = 60.0
	static let hour: TimeInterval = 60.0 * 60.0
	static let day: TimeInterval = 60.0 * 60.0 * 24.0
	
	static var saveInterval: TimeInterval = 20.0
	static var keyPressSearchDelay: TimeInterval = 0.5
	static var pressAndHoldInterval: TimeInterval = 1.0

	
	var days: Int { return abs(Int(self / .day)) }
	var hours: Int { return abs(Int(self / .hour)) }
	var minutes: Int { return abs(Int(self / .minute)) }
	var seconds: Int { return abs(Int(self)) }

	var leftoverHours: Int { return Int(self / .hour) % 24 }
	var leftoverMinutes: Int { return Int(self / .minute) % 60 }
	var leftoverSeconds: Int { return Int(self) % 60 }

	enum DurationStyle { case hours, minutes, seconds, centiseconds, milliseconds }
	
	func durationString(style: DurationStyle = .seconds, showLeadingZero: Bool = false) -> String {
		var leading = showLeadingZero ? "%02d" : "%d"
		if self < 0 { leading = "-" + leading }

		switch style {
		case .hours:
			return String(format: leading, hours)
			
		case .minutes:
			let minutes = abs(Int((self / .minute).rounded(.up)))
			return String(format: leading + ":%02d", hours, minutes % 60)

		case .seconds:
			let seconds = abs(Int(self.rounded(.up)))
			if hours > 0 { return String(format: leading + ":%02d:%02d", hours, minutes % 60, seconds % 60) }
			return String(format: leading + ":%02d", minutes % 60, seconds % 60)

		case .centiseconds:
			if hours > 0 { return String(format: leading + ":%02d:%02d.%02d", hours, minutes % 60, seconds % 60, Int(self * 100) % 100) }
			return String(format: leading + ":%02d.%02d", minutes % 60, seconds % 60, Int(self * 100) % 100)

		case .milliseconds:
			if hours > 0 { return String(format: leading + ":%02d:%02d.%02d", hours, minutes % 60, seconds % 60, Int(self * 1000) % 1000) }
			return String(format: leading + "%02d.%02d", minutes % 60, seconds % 60, Int(self * 1000) % 1000)

		}
	}
	
	func durationWords(includingSeconds: Bool = true, abbreviated: Bool = false) -> String {
		var components: [String] = []
		
		let hourString = abbreviated ? NSLocalizedString("hr", comment: "hr") : NSLocalizedString("hour", comment: "hour")
		let minuteString = abbreviated ? NSLocalizedString("min", comment: "min") : NSLocalizedString("minute", comment: "minute")
		let secondString = abbreviated ? NSLocalizedString("sec", comment: "sec") : NSLocalizedString("second", comment: "second")

		if hours != 0 { components.append(Pluralizer.instance.pluralize(hours, hourString)) }
		if leftoverMinutes != 0 { components.append(Pluralizer.instance.pluralize(leftoverMinutes, minuteString)) }
		if includingSeconds, leftoverSeconds != 0 { components.append(Pluralizer.instance.pluralize(leftoverSeconds, secondString)) }
		
		return components.joined(separator: ", ")
	}
	
	init?(string: String?) {
		guard let string = string else { return nil }
		let comps = string.components(separatedBy: ":")
		
		switch comps.count {
		case 0:
			self = 0
			return nil
			
		case 1:
			guard let secs = Double(comps[0]) else {
				self = 0
				return nil
			}
			self = TimeInterval(secs)
			
		case 2:
			guard let mins = Int(comps[0]), let secs = Double(comps[1]) else {
				self = 0
				return nil
			}
			self = TimeInterval(secs + Double(mins) * 60)

		case 3:
			guard let hrs = Int(comps[0]), let mins = Int(comps[1]), let secs = Double(comps[2]) else {
				self = 0
				return nil
			}
			self = TimeInterval(secs + Double(mins) * 60 + Double(hrs) * 3600)
			
		default:
			self = 0
			return nil
		}
	}
}
