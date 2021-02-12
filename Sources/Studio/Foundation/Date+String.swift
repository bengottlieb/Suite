//
//  Date+String.swift
//  
//
//  Created by Ben Gottlieb on 2/12/21.
//

import Foundation

public extension Date {
	enum DateStringStyle { case none, abbr, short, medium, long, full
		var dateFormatterStyle: DateFormatter.Style {
			switch self {
			case .none: return .none
			case .abbr: return .short
			case .short: return .short
			case .medium: return .medium
			case .long: return .long
			case .full: return .full
			}
		}
		
	}
	enum TimeStringStyle { case none, short, medium, long, full }

	func localTimeString(date dateStyle: DateStringStyle = .short, time timeStyle: DateStringStyle = .short) -> String {
		let formatter = DateFormatter()
		
		let replaceableAMSymbol = "[_AM_]"
		let replaceablePMSymbol = "[_PM_]"

		if timeStyle == .abbr {
			formatter.amSymbol = replaceableAMSymbol
			formatter.pmSymbol = replaceablePMSymbol
		}

		formatter.dateStyle = dateStyle.dateFormatterStyle
		formatter.timeStyle = timeStyle.dateFormatterStyle
		
		var result = formatter.string(from: self)
		
		if timeStyle == .abbr {
			result = result.replacingOccurrences(of: ":00 \(replaceableAMSymbol)", with: "a")
			result = result.replacingOccurrences(of: ":00 \(replaceablePMSymbol)", with: "p")

			result = result.replacingOccurrences(of: replaceableAMSymbol, with: "a")
			result = result.replacingOccurrences(of: replaceablePMSymbol, with: "p")
		}
		
		return result
	}
}
