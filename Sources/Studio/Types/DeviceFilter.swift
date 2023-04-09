//
//  DeviceFilter.swift
//  
//
//  Created by Ben Gottlieb on 4/9/23.
//

import Foundation

public struct DeviceFilter: RawRepresentable, OptionSet {
	public var rawValue: Int
	
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}
}

public extension DeviceFilter {
	static let never = DeviceFilter([])
	
	static let sim = DeviceFilter(rawValue: 1 << 1)
	static let device = DeviceFilter(rawValue: 1 << 2)

	static let iPhone = DeviceFilter(rawValue: 1 << 3)
	static let iPad = DeviceFilter(rawValue: 1 << 4)
	static let watch = DeviceFilter(rawValue: 1 << 5)
	static let mac = DeviceFilter(rawValue: 1 << 6)
	static let tv = DeviceFilter(rawValue: 1 << 7)
	static let iOS = DeviceFilter(rawValue: 1 << 8)

	static let debug = DeviceFilter(rawValue: 1 << 9)
	static let testFlight = DeviceFilter(rawValue: 1 << 10)
	static let prod = DeviceFilter(rawValue: 1 << 11)

	var matches: Bool {
		if contains(.sim) {
			if !Gestalt.isOnMac, !Gestalt.isOnSimulator { return false }
		}
		
		if contains(.iOS), !Gestalt.isOnIPad && !Gestalt.isOnIPhone { return false }
		if contains(.iPad), !Gestalt.isOnIPad { return false }
		if contains(.iPhone), !Gestalt.isOnIPhone { return false }
		if contains(.watch), !Gestalt.isOnWatch { return false }
		if contains(.tv), !Gestalt.isOnTV { return false }
		if contains(.mac), !Gestalt.isOnMac { return false }

		if contains(.prod), Gestalt.distribution != .appStore { return false }
		if contains(.debug), Gestalt.distribution != .development { return false }
		if contains(.testFlight), Gestalt.distribution != .testflight { return false }

		return true
	}
}
