//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 11/28/22.
//

#if os(macOS)
import Foundation
import IOKit
import IOKit.pwr_mgt
import Cocoa

extension NSApplication {
	public var sleepDisabled: Bool {
		set {
			if newValue {
				DisableSleep.instance.disableScreenSleep()
			} else {
				DisableSleep.instance.enableScreenSleep()
			}
		}
		
		get { DisableSleep.instance.sleepDisabled }
	}
}

class DisableSleep {
	static let instance = DisableSleep()
	var assertionID: IOPMAssertionID = 0
	
	
	var sleepDisabled = false
	func disableScreenSleep(reason: String = "Disabling Screen Sleep") {
		if !sleepDisabled {
			sleepDisabled = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn), reason as CFString, &assertionID) == kIOReturnSuccess
		}
	}

	func enableScreenSleep() {
		if sleepDisabled {
			IOPMAssertionRelease(assertionID)
			assertionID = 0
			sleepDisabled = false
		}
		
	}
	
}
#endif
