//
//  Date.DateTag.swift
//  
//
//  Created by Ben Gottlieb on 4/11/23.
//

import Foundation

public extension Date {
	enum DateTagStyle: String {
		case compact = "%d-%d-%d.%d.%d"
		case seconds = "%d-%d-%d.%d.%d.%d"

		case compactColon = "%d-%d-%d.%d:%d"
		case secondsColon = "%d-%d-%d.%d:%d:%d"

	}
	
	func dateTag(_ style: DateTagStyle = .compact) -> String {
		String(format: style.rawValue, year, month.rawValue, dayOfMonth, hour, minute, second)
	}
}

public extension String {
	static var dateTag: String { Date().dateTag() }
}
