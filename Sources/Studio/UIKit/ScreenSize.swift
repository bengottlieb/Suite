//
//  ScreenSize.swift
//  
//
//  Created by Ben Gottlieb on 6/30/21.
//

#if canImport(UIKit)
import UIKit

public struct ScreenSize {
	public let width: Int
	public let height: Int
	
	init(_ w: Int, _ h: Int) { width = min(w, h); height = max(w, h) }
}

extension ScreenSize: Equatable {
	public static func ==(lhs: ScreenSize, rhs: ScreenSize) -> Bool {
		lhs.width == rhs.width && lhs.height == rhs.height
	}

	public static func ==(lhs: ScreenSize, rhs: CGSize) -> Bool {
		lhs.width == Int(rhs.width) && lhs.height == Int(rhs.height)
	}
}

public extension CGSize {
	var screenSize: ScreenSize {
		ScreenSize.nearest(to: self)
	}
}

public extension ScreenSize {
	static let iPhone12ProMax = ScreenSize(428, 926)
	static let iPhone12 = ScreenSize(390, 844)
	static let iPhone11ProMax = ScreenSize(414, 896)
	static let iPhoneX = ScreenSize(375, 812)
	static let iPhoneSixPlus = ScreenSize(414, 736)
	static let iPhoneSix = ScreenSize(375, 667)
	static let iPhone5 = ScreenSize(320, 568)
	static let iPhone = ScreenSize(320, 480)
	
	static let iPadPro11 = ScreenSize(834, 1194)
	static let iPadPro10_5 = ScreenSize(834, 1112)
	static let iPadPro12_9 = ScreenSize(1024, 1366)
	static let iPadAir_4thGen = ScreenSize(820, 1180)
	static let iPad_7thGen = ScreenSize(810, 1080)
	static let iPad = ScreenSize(768, 1024)

	static let phones: [ScreenSize] = [.iPhone, .iPhone5, .iPhoneSix, .iPhoneSixPlus, .iPhoneX, .iPhone11ProMax, .iPhone12, .iPhone12ProMax]
	static let pads: [ScreenSize] = [.iPadPro11, iPadPro10_5, iPadPro12_9, iPadAir_4thGen, iPad_7thGen, iPad]

	static func nearest(to size: CGSize) -> ScreenSize {
		var diff = 1000000
		var closest = iPhone
		
		for phoneSize in phones + pads {
			if phoneSize == size { return phoneSize }
			let currentDiff = abs(phoneSize.width - Int(size.width)) + abs(phoneSize.height - Int(size.height))
			if currentDiff < diff {
				diff = currentDiff
				closest = phoneSize
			}
		}
		return closest
	}
}


#endif
