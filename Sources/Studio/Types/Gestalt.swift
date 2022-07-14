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
	public enum Distribution { case development, testflight, appStore }
	
	
	public static var distribution: Distribution {
		#if DEBUG
			return .development
		#else
			#if os(OSX)
				let bundlePath = Bundle.main.bundleURL
				let receiptURL = bundlePath.appendingPathComponent("Contents").appendingPathComponent("_MASReceipt").appendingPathComponent("receipt")
				
				return FileManager.default.fileExists(at: receiptURL) ? .appStore : .development
			#else
				if isOnSimulator { return .development }
				if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" && MobileProvisionFile.default?.properties["ProvisionedDevices"] == nil { return .testflight }
				
				return .appStore
			#endif
		#endif
	}
	public enum DebugLevel: Int, Comparable { case none, testFlight, internalTesting, debugging
		public static func < (lhs: Gestalt.DebugLevel, rhs: Gestalt.DebugLevel) -> Bool { return lhs.rawValue < rhs.rawValue }
	}
	public static var debugLevel = Gestalt.isAttachedToDebugger ? DebugLevel.debugging : DebugLevel.none
	
	#if targetEnvironment(simulator)
		public static var isOnSimulator: Bool { return true }
	#else
		public static var isOnSimulator: Bool { return false }
	#endif
	
	public static var isAttachedToDebugger: Bool = { return isatty(STDERR_FILENO) != 0 }()
	
	public static func ensureMainThread(message: String? = nil) {
		assert(Thread.isMainThread, "must run on main thread \(message ?? "--")!")
	}
	
	public static var isExtension: Bool = {
		let extensionDictionary = Bundle.main.infoDictionary?["NSExtension"]
		return extensionDictionary is NSDictionary
	}()
	
	public static var isInPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
	
	#if os(OSX)
		public static var isOnMac: Bool { return true }
		
		public static var rawDeviceType: String {
			let service: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
			let cfstr = "model" as CFString
			if let model = IORegistryEntryCreateCFProperty(service, cfstr, kCFAllocatorDefault, 0).takeUnretainedValue() as? Data {
			  if let nsstr =  String(data: model, encoding: .utf8) {
					  return nsstr
				 }
			}
			return ""
	}
	static public var deviceName: String { rawDeviceType }
	#endif
	
	#if os(iOS)
		static public var deviceName: String { UIDevice.current.name }
		#if targetEnvironment(macCatalyst)
			public static var isOnMac: Bool { return true }
		#else
			public static var isOnMac: Bool { return false }
		#endif
		public static var isOnIPad: Bool = { return UIDevice.current.userInterfaceIdiom == .pad }()
		public static var isOnIPhone: Bool = { return UIDevice.current.userInterfaceIdiom == .phone }()
    
		public static var osMajorVersion: Int = {
			return Int(UIDevice.current.systemVersion.components(separatedBy: ".").first ?? "") ?? 0
		}()
	
		enum SimulatorHostInfo: Int, CaseIterable { case sysname = 0, nodename, release, version, machine }
		static func getSimulatorHostInfo(which: SimulatorHostInfo) -> String? {
			let structSize = MemoryLayout<utsname>.size
			let fieldSize = structSize / SimulatorHostInfo.allCases.count
			var systemInfo = [UInt8](repeating: 0, count: structSize)
			
			let info = systemInfo.withUnsafeMutableBufferPointer { ( body: inout UnsafeMutableBufferPointer<UInt8>) -> String? in
				var valid = false
				guard let base = body.baseAddress else { return nil }
				base.withMemoryRebound(to: utsname.self, capacity: 1) { data in
					valid = uname(data) == 0
				}

				if !valid { return nil }

				let all = Array(body)
				let offset = which.rawValue * fieldSize
				let chunk = Array(all[offset..<(offset + fieldSize)])
				let count = chunk.firstIndex(where: { $0 == 0 }) ?? fieldSize
				return String(bytes: chunk[0..<count], encoding: .utf8)
			}
			return info
		}
		public static var simulatorMachineName: String? { return self.getSimulatorHostInfo(which: .nodename) }
		public static var simulatorSystemName: String? { return self.getSimulatorHostInfo(which: .sysname) }
		public static var simulatorReleaseName: String? { return self.getSimulatorHostInfo(which: .release) }
		public static var simulatorVersionName: String? { return self.getSimulatorHostInfo(which: .version) }
		public static var simulatorCPUName: String? { return self.getSimulatorHostInfo(which: .machine) }

		public static var simulatorInfo: String {
			SimulatorHostInfo.allCases.map { getSimulatorHostInfo(which: $0) }.compactMap { $0 }.joined(separator: "- ")
		}

	#endif
	
	#if os(iOS) || os(watchOS)
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
	
		public static var modelName: String {
			convertRawDeviceTypeToModelName(rawDeviceType) ?? "unknown"
		}
	
		public static func convertRawDeviceTypeToModelName(_ raw: String) -> String? {
			switch raw {
			case "iPod5,1":                           return "iPod Touch 5"
			case "iPod7,1":                           return "iPod Touch 6"
			case "iPod8,1":                           return "iPod Touch 7"
			case "iPod9,1":									return "iPod Touch 7"
				
			case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
			case "iPhone4,1":                         return "iPhone 4s"
			case "iPhone5,1", "iPhone5,2":            return "iPhone 5"
			case "iPhone5,3", "iPhone5,4":            return "iPhone 5c"
			case "iPhone6,1", "iPhone6,2":            return "iPhone 5s"
			case "iPhone7,2":                         return "iPhone 6"
			case "iPhone7,1":                         return "iPhone 6 Plus"
			case "iPhone8,1":                         return "iPhone 6s"
			case "iPhone8,2":                         return "iPhone 6s Plus"
			case "iPhone9,1", "iPhone9,3":            return "iPhone 7"
			case "iPhone9,2", "iPhone9,4":				return "iPhone 7 Plus"
			case "iPhone8,4":									return "iPhone SE"
			case "iPhone10,1", "iPhone10,4":				return "iPhone 8"
			case "iPhone10,2", "iPhone10,5":				return "iPhone 8 Plus"
			case "iPhone10,3", "iPhone10,6":				return "iPhone X"
			case "iPhone11,8":								return "iPhone Xr"
			case "iPhone11,2":								return "iPhone Xs"
			case "iPhone11,4", "iPhone11,6":				return "iPhone Xs max"

			case "iPhone12,1":								return "iPhone 11"
			case "iPhone12,3":								return "iPhone 11 Pro"
			case "iPhone12,5":								return "iPhone 11 Pro max"
			case "iPhone12,8":								return "iPhone SE 2nd gen"

			case "iPhone13,1":								return "iPhone 12 mini"
			case "iPhone13,2":								return "iPhone 12"
			case "iPhone13,3":								return "iPhone 12 Pro"
			case "iPhone13,4":								return "iPhone 12 Pro max"

			case "iPad2,5", "iPad2,6", "iPad2,7":     return "iPad Mini"
			case "iPad4,4", "iPad4,5", "iPad4,6":     return "iPad Mini 2"
			case "iPad4,7", "iPad4,8", "iPad4,9":     return "iPad Mini 3"
			case "iPad5,1", "iPad5,2":                return "iPad Mini 4"
			case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
																	return "iPad 2"
			case "iPad3,1", "iPad3,2", "iPad3,3":     return "iPad 3"
			case "iPad3,4", "iPad3,5", "iPad3,6":     return "iPad 4"
			case "iPad4,1", "iPad4,2", "iPad4,3":     return "iPad Air"
			case "iPad5,3", "iPad5,4":                return "iPad Air 2"
			case "iPad6,4":									return "iPad Pro 9.7 in."
			case "iPad6,7", "iPad6,8":                return "iPad Pro 12.9 in."
			case "iPad7,4":									return "iPad Pro 10.5 in."
			case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":
																	return "iPad Pro 11 in."
			case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":
																	return "iPad Pro 12.9 in."
			case "iPad8,10":									return "iPad Pro 11 in. 4th gen"
			case "iPad8,11", "iPad8,12":					return "iPad Pro 12.9 in. 4th gen"
			case "iPad11,3", "iPad11,4": 					return "iPad Air 3"
			case "iPad11,1", "iPad11,2": 					return "iPad mini 5"
			case "iPad11,6", "iPad11,7": 					return "iPad 8th gen"
			case "iPad13,1", "iPad13,2": 					return "iPad air 4th gen"

			case "Watch1,1": 									return "Apple Watch Series 0 38mm"
			case "Watch1,2": 									return "Apple Watch Series 0 42mm"
			case "Watch2,6": 									return "Apple Watch Series 1 38mm"
			case "Watch2,7": 									return "Apple Watch Series 1 42mm"
			case "Watch2,3": 									return "Apple Watch Series 2 38mm"
			case "Watch2,4": 									return "Apple Watch Series 2 42mm"
			case "Watch3,1", "Watch3,3": 					return "Apple Watch Series 3 38mm"
			case "Watch3,2", "Watch3,4": 					return "Apple Watch Series 3 42mm"
			case "Watch4,1", "Watch4,3": 					return "Apple Watch Series 4 40mm"
			case "Watch4,2", "Watch4,4": 					return "Apple Watch Series 4 44mm"
			case "Watch5,1", "Watch5,3": 					return "Apple Watch Series 5 40mm"
			case "Watch5,2", "Watch5,4": 					return "Apple Watch Series 5 44mm"

			case "Watch5,9", "Watch5,11":					return "Apple Watch SE 40mm"
			case "Watch5,10", "Watch5,12":				return "Apple Watch SE 44mm"

			case "Watch6,1", "Watch6,3": 					return "Apple Watch Series 6 40mm"
			case "Watch6,2", "Watch6,4": 					return "Apple Watch Series 6 44mm"
			case "Watch6,6", "Watch6,8": 					return "Apple Watch Series 7 41mm"
			case "Watch6,7", "Watch6,9": 					return "Apple Watch Series 7 45mm"

			case "AppleTV1,1": 								return "Apple TV 1st gen"
			case "AppleTV2,1": 								return "Apple TV 2nd gen"
			case "AppleTV3,1": 								return "Apple TV 3rd gen"
			case "AppleTV3,2": 								return "Apple TV 3rd gen"
			case "AppleTV5,3": 								return "Apple TV HD 4th gen"
			case "AppleTV6,2": 								return "Apple TV 4K"
				
			default: return nil
			}
		}
	
//		public static var deviceType: String = {
//			let raw = Gestalt.rawDeviceType
//			switch raw {
//			case "i386", "x86_64":
//				let screenSize = UIScreen.main.bounds.size
//				let size = (Int(screenSize.width), Int(screenSize.height))
//				let scale = Int(UIScreen.main.scale)
//
//				switch size {
//				case (320, 480): return "Simulator, iPhone 4"
//				case (320, 568):
//					return "Simulator, iPhone 5" + (raw == "x86_64" ? "s" : "")
//				case (375, 667): return "Simulator, iPhone 7"
//				case (414, 736): return "Simulator, iPhone 7+"
//				case (768, 1024):
//					if raw == "x86_64" { return "Simulator, iPad air" }
//					return "Simulator, iPad " + (scale == 1 ? "2" : "4")
//				case (1024, 1366): return "Simulator, iPad Pro"
//				default: return "Simulator, \(size.0)x\(size.1) @\(scale)x"
//				}
//
//
//			default: return Gestalt.convertRawDeviceTypeToModelName(raw) ?? raw
//			}
//		}()
	
		public static var isRunningUITests: Bool {
			return ProcessInfo.processInfo.arguments.contains("-ui_testing")
		}
	
	
	#else
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
	
	public static var IPAddress: String? {
		 var address: String?
		 var ifaddr: UnsafeMutablePointer<ifaddrs>?
		 if getifaddrs(&ifaddr) == 0 {
			  var ptr = ifaddr
			  while ptr != nil {
					defer { ptr = ptr?.pointee.ifa_next }
					let interface = ptr?.pointee
					let addrFamily = interface?.ifa_addr.pointee.sa_family
					if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6),
						 let cString = interface?.ifa_name,
						 String(cString: cString) == "en0",
						 let saLen = (interface?.ifa_addr.pointee.sa_len) {
						 var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
						 let ifaAddr = interface?.ifa_addr
						 getnameinfo(ifaAddr,
										 socklen_t(saLen),
										 &hostname,
										 socklen_t(hostname.count),
										 nil,
										 socklen_t(0),
										 NI_NUMERICHOST)
						 address = String(cString: hostname)
					}
			  }
			  freeifaddrs(ifaddr)
		 }
		 return address
	}
	
	public static var buildDate: Date? { Bundle.main.executableURL?.createdAt }
}
