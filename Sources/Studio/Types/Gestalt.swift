//
//  MobileProvisionFile.swift
//  Suite
//
//  Created by Ben Gottlieb on 9/9/19.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

#if os(iOS)
	import UIKit
#endif



public struct Gestalt {
	public enum DebugLevel: Int, Comparable { case none, testFlight, internalTesting, debugging
		public static func < (lhs: Gestalt.DebugLevel, rhs: Gestalt.DebugLevel) -> Bool { return lhs.rawValue < rhs.rawValue }
	}
	public static var debugLevel = Gestalt.isAttachedToDebugger ? DebugLevel.debugging : DebugLevel.none
	
	#if targetEnvironment(simulator)
		public static var runningOnSimulator: Bool { return true }
	#else
		public static var runningOnSimulator: Bool { return false }
	#endif
	
	public static var isAttachedToDebugger: Bool = { return isatty(STDERR_FILENO) != 0 }()
	
	public static func ensureMainThread(message: String? = nil) {
		assert(Thread.isMainThread, "must run on main thread \(message ?? "--")!")
	}
	
	public static var isExtension: Bool = {
		let extensionDictionary = Bundle.main.infoDictionary?["NSExtension"]
		return extensionDictionary is NSDictionary
	}()
	
	#if os(OSX)
		public static var isOnMac: Bool { return true }
		
		public var rawDeviceType: String {
			let service: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
			let cfstr = "model" as CFString
			if let model = IORegistryEntryCreateCFProperty(service, cfstr, kCFAllocatorDefault, 0).takeUnretainedValue() as? Data {
			  if let nsstr =  String(data: model, encoding: .utf8) {
					  return nsstr
				 }
			}
			return ""
	}
	#endif
	
	#if os(watchOS)
		public static var isOnMac: Bool { return false }
	#endif
	
	#if os(iOS)
		#if targetEnvironment(macCatalyst)
			public static var isOnMac: Bool { return true }
		#else
			public static var isOnMac: Bool { return false }
		#endif
		public static var isOnIPad: Bool = { return UIDevice.current.userInterfaceIdiom == .pad }()
		public static var isOnIPhone: Bool = { return UIDevice.current.userInterfaceIdiom == .phone }()
        public static var isTestflightBuild: Bool = {
            return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" && MobileProvisionFile.default?.properties["ProvisionedDevices"] == nil
        }()
    
        public static var isAppStoreBuild: Bool = { return !Gestalt.runningOnSimulator && !Gestalt.isTestflightBuild && !Gestalt.hasEmbeddedMobileProvision }()
		public static var isProductionBuild: Bool = { return !Gestalt.runningOnSimulator && !Gestalt.hasEmbeddedMobileProvision }()
	
        private static var hasEmbeddedMobileProvision: Bool = {
            return Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
        }()
    
		public static var osMajorVersion: Int = {
			return Int(UIDevice.current.systemVersion.components(separatedBy: ".").first ?? "") ?? 0
		}()
	
		enum SimulatorHostInfo: Int32 { case Sysname = 0, Nodename, Release, Version, Machine }
		static func getSimulatorHostInfo(which: SimulatorHostInfo) -> String? {
			let structSize = MemoryLayout<utsname>.size
			let fieldSize = structSize / 5
			var systemInfo = [UInt8](repeating: 0, count: structSize)
			
			let info = systemInfo.withUnsafeMutableBufferPointer { ( body: inout UnsafeMutableBufferPointer<UInt8>) -> String? in
				var valid = false
				body.baseAddress?.withMemoryRebound(to: utsname.self, capacity: 1) { data in
					valid = uname(data) == 0
				}

				if !valid { return nil }

				var result: String? = nil
				
				body.baseAddress?.withMemoryRebound(to: CChar.self, capacity: 1) { data in
					result = String(validatingUTF8: &data[Int(which.rawValue) * fieldSize])
				}
				return result
			}
			return info
		}
	
		public static var simulatorMachineName: String? { return self.getSimulatorHostInfo(which: .Nodename) }
		public static var simulatorSystemName: String? { return self.getSimulatorHostInfo(which: .Sysname) }
		public static var simulatorReleaseName: String? { return self.getSimulatorHostInfo(which: .Release) }
		public static var simulatorVersionName: String? { return self.getSimulatorHostInfo(which: .Version) }
		public static var simulatorCPUName: String? { return self.getSimulatorHostInfo(which: .Machine) }
		public static var rawDeviceType: String {
			var			systemInfo = utsname()
			uname(&systemInfo)
			let machineMirror = Mirror(reflecting: systemInfo.machine)
			let identifier = machineMirror.children.reduce("") { identifier, element in
				guard let value = element.value as? Int8 , value != 0 else { return identifier }
				return identifier + String(UnicodeScalar(UInt8(value)))
			}
			return identifier
		}
	
		public static func convertRawDeviceTypeToModelName(_ raw: String) -> String? {
			switch raw {
			case "iPod5,1":                                 return "iPod Touch 5"
			case "iPod7,1":                                 return "iPod Touch 6"
			case "iPod8,1":                                 return "iPod Touch 7"
			case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
			case "iPhone4,1":                               return "iPhone 4s"
			case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
			case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
			case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
			case "iPhone7,2":                               return "iPhone 6"
			case "iPhone7,1":                               return "iPhone 6 Plus"
			case "iPhone8,1":                               return "iPhone 6s"
			case "iPhone8,2":                               return "iPhone 6s Plus"
			case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
			case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
			case "iPhone8,4":								return "iPhone SE"
			case "iPhone10,1", "iPhone10,4":				return "iPhone 8"
			case "iPhone10,2", "iPhone10,5":				return "iPhone 8 Plus"
			case "iPhone10,3", "iPhone10,6":				return "iPhone X"
			case "iPhone11,8":								return "iPhone Xr"
			case "iPhone11,2":								return "iPhone Xs"
			case "iPhone11,6":								return "iPhone Xs max"

			case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
			case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
			case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
			case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
			case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
			case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
			case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
			case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
			case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
			case "iPad6,4":									return "iPad Pro 9.7 in."
			case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 in."
			case "iPad7,4":									return "iPad Pro 10.5 in."
			case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro 11 in."
			case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro 12.9 in."
			case "iPad11,3", "iPad11,4": 					return "iPad Air 3"
			case "iPad11,1", "iPad11,2": 					return "iPad mini 5"

			case "AppleTV5,3":                              return "Apple TV"
			default: return nil
			}
		}
	
		public static var deviceType: String = {
			let raw = Gestalt.rawDeviceType
			switch raw {
			case "i386", "x86_64":
				let screenSize = UIScreen.main.bounds.size
				let size = (Int(screenSize.width), Int(screenSize.height))
				let scale = Int(UIScreen.main.scale)

				switch size {
				case (320, 480): return "Simulator, iPhone 4"
				case (320, 568):
					return "Simulator, iPhone 5" + (raw == "x86_64" ? "s" : "")
				case (375, 667): return "Simulator, iPhone 7"
				case (414, 736): return "Simulator, iPhone 7+"
				case (768, 1024):
					if raw == "x86_64" { return "Simulator, iPad air" }
					return "Simulator, iPad " + (scale == 1 ? "2" : "4")
				case (1024, 1366): return "Simulator, iPad Pro"
				default: return "Simulator, \(size.0)x\(size.1) @\(scale)x"
				}
				
				
			default: return Gestalt.convertRawDeviceTypeToModelName(raw) ?? raw
			}
		}()
	
		public static var simulatorInfo: String {
			let pieces: [SimulatorHostInfo] = [.Nodename, .Sysname, .Release, .Version, .Machine ]
			var result = ""
			for piece in pieces {
				if let info = self.getSimulatorHostInfo(which: piece) { result += (result.isEmpty ? "" : "- ") + info }
			}
			return result
		}
	
		public static var isRunningUITests: Bool {
			return ProcessInfo.processInfo.arguments.contains("-ui_testing")
		}
	
	
	#else
		public static var isTestflightBuild: Bool = false
		
		public static var isAppStoreBuild: Bool = {
			let bundlePath = Bundle.main.bundleURL
			let receiptURL = bundlePath.appendingPathComponent("Contents").appendingPathComponent("_MASReceipt").appendingPathComponent("receipt")
			
			return FileManager.default.fileExists(at: receiptURL)
		}()
		
		public static var isProductionBuild: Bool = {
			return Gestalt.isAppStoreBuild
		}()
	
		#if os(OSX)
			public static var serialNumber: String? = {
				let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
				
				let string = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0).takeRetainedValue()
				return string as? String
			}()
		#endif
	
	#endif
	
	public static var isRunningUnitTests: Bool = {
		return NSClassFromString("XCTest") != nil
	}()
}
