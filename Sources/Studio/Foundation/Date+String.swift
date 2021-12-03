//
//  Date+String.swift
//  
//
//  Created by Ben Gottlieb on 2/12/21.
//

import Foundation

public extension Date {
	enum DateStringStyle { case none, minimal, abbr, short, medium, long, full
		var dateFormatterStyle: DateFormatter.Style {
			switch self {
			case .none: return .none
			case .minimal: return .short
			case .abbr: return .short
			case .short: return .short
			case .medium: return .medium
			case .long: return .long
			case .full: return .full
			}
		}
	}
	
	func localTimeString(date dateStyle: DateStringStyle = .short, time timeStyle: DateStringStyle = .short) -> String {
		let formatter = DateFormatter()
		
		let replaceableAMSymbol = "[_AM_]"
		let replaceablePMSymbol = "[_PM_]"

		if timeStyle == .abbr || timeStyle == .minimal {
			formatter.amSymbol = replaceableAMSymbol
			formatter.pmSymbol = replaceablePMSymbol
		}

		formatter.dateStyle = dateStyle.dateFormatterStyle
		formatter.timeStyle = timeStyle.dateFormatterStyle
		
		var result = formatter.string(from: self)
		
		if timeStyle == .minimal {
			result = result.replacingOccurrences(of: ":00 \(replaceableAMSymbol)", with: "")
			result = result.replacingOccurrences(of: ":00 \(replaceablePMSymbol)", with: "")

			result = result.replacingOccurrences(of: replaceableAMSymbol, with: "")
			result = result.replacingOccurrences(of: replaceablePMSymbol, with: "")
		} else if timeStyle == .abbr {
			result = result.replacingOccurrences(of: ":00 \(replaceableAMSymbol)", with: "a")
			result = result.replacingOccurrences(of: ":00 \(replaceablePMSymbol)", with: "p")

			result = result.replacingOccurrences(of: replaceableAMSymbol, with: "a")
			result = result.replacingOccurrences(of: replaceablePMSymbol, with: "p")
		}
		
		return result
	}
	
	var filesystemRepresentation: String {
		let formatter = DateFormatter(format: "yyyy-MM-dd'T'HH;mm;ss")
		
		return formatter.string(from: self)
	}

}
