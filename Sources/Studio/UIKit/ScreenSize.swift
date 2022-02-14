//
//  ScreenSize.swift
//  
//
//  Created by Ben Gottlieb on 6/30/21.
//

#if canImport(UIKit)
import UIKit

public extension CGSize {
	var screenSize: IntSize {
		IntSize.nearest(to: self)
	}
}

public extension IntSize {
	static let iPhone12ProMax = IntSize(screenW: 428, 926)
	static let iPhone12 = IntSize(screenW: 390, 844)
	static let iPhone11ProMax = IntSize(screenW: 414, 896)
	static let iPhoneX = IntSize(screenW: 375, 812)
	static let iPhoneSixPlus = IntSize(screenW: 414, 736)
	static let iPhoneSix = IntSize(screenW: 375, 667)
	static let iPhone5 = IntSize(screenW: 320, 568)
	static let iPhone = IntSize(screenW: 320, 480)
	
	static let iPadPro11 = IntSize(screenW: 834, 1194)
	static let iPadPro10_5 = IntSize(screenW: 834, 1112)
	static let iPadPro12_9 = IntSize(screenW: 1024, 1366)
	static let iPadAir_4thGen = IntSize(screenW: 820, 1180)
	static let iPad_7thGen = IntSize(screenW: 810, 1080)
	static let iPad = IntSize(screenW: 768, 1024)

	static let phones: [IntSize] = [.iPhone, .iPhone5, .iPhoneSix, .iPhoneSixPlus, .iPhoneX, .iPhone11ProMax, .iPhone12, .iPhone12ProMax]
	static let pads: [IntSize] = [.iPadPro11, iPadPro10_5, iPadPro12_9, iPadAir_4thGen, iPad_7thGen, iPad]

	static func nearest(to size: CGSize) -> IntSize {
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
