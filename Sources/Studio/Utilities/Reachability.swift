#if canImport(SystemConfiguration)
import SystemConfiguration
import Foundation

#if canImport(UIKit) && !os(watchOS)
	import UIKit
#endif

#if canImport(Combine)
	import SwiftUI

	@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
	extension Reachability: ObservableObject {
		func objectChanged() {
			self.objectWillChange.send()
		}
	}
#else
extension Reachability {
	func objectChanged() {
	
	}
}
#endif

public extension URLSessionTask {
	@discardableResult
	func start(andWarnIfOffline warn: Bool = true) -> Bool {
		if Reachability.instance.isOffline {
			if warn {
				Reachability.instance.showOfflineWarning()
			}
			return false
		} else {
			self.resume()
			return true
		}
	}
}

public class Reachability {
	public static let instance = Reachability().startNotifier()
	
	public enum ReachabilityError: Error { case offline }
	
	public struct Notifications {
		static let reachabilityChanged = Notification.Name("Reachability.Notifications.reachabilityChanged")
	}
	
	public enum Connection: CustomStringConvertible {
		case none, unavailable, wifi, cellular
		public var description: String {
			switch self {
			case .cellular: return NSLocalizedString("Cellular", comment: "Cellular")
			case .wifi: return NSLocalizedString("WiFi", comment: "WiFi")
			case .unavailable: return NSLocalizedString("No Connection", comment: "No Connection")
			case .none: return NSLocalizedString("Unavailable", comment: "Unavailable")
			}
		}
	}
	
	public typealias ReachableCallback = (Reachability) -> ()
	var reachabilityCallbacks: [Int: ReachableCallback] = [:]
	
	public func register<Kind: Hashable>(for object: Kind, callback: @escaping ReachableCallback) {
		self.reachabilityCallbacks[object.hashValue] = callback
	}
	
	public func unregister<Kind: Hashable>(for object: Kind) {
		self.reachabilityCallbacks.removeValue(forKey: object.hashValue)
	}
	
	#if canImport(UIKit) && !os(watchOS)
		public var alertDisplayController: UIViewController?
		public func showOfflineWarning(in controller: UIViewController? = nil) {
			guard self.isOffline, let presenter = controller ?? self.alertDisplayController else { return }
			let alert = UIAlertController(title: NSLocalizedString("Offline", comment: "Offline"), message: NSLocalizedString("You're not connected to the internet.", comment: "You're not connected to the internet."))
			
			presenter.presentedest.present(alert, animated: true, completion: nil)
		}
	#else
		public func showOfflineWarning() {
		
		}
	#endif
	
	public var allowsCellularConnection: Bool
	
	public var connection: Connection {
		if self.flags == nil { self.setReachabilityFlags() }
		
		switch flags?.connection ?? .unavailable {
		case .unavailable, nil: return .unavailable
		case .none: return .unavailable
		case .cellular: return allowsCellularConnection ? .cellular : .unavailable
		case .wifi: return .wifi
		}
	}
	
	var notifierRunning = false
	let reachabilityRef: SCNetworkReachability
	let reachabilitySerialQueue = DispatchQueue(label: "suite.reachability", qos: .userInitiated, target: .main)
	var flags: SCNetworkReachabilityFlags? {
		didSet {
			if self.flags != oldValue { self.notifyReachabilityChanged() }
		}
	}
	
	init(reachabilityRef: SCNetworkReachability = .default) {
		self.allowsCellularConnection = true
		self.reachabilityRef = reachabilityRef
	}
	
	deinit {
		stopNotifier()
	}
}

extension SCNetworkReachability {
	static var `default`: SCNetworkReachability {
		var zeroAddress = sockaddr()
		zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
		zeroAddress.sa_family = sa_family_t(AF_INET)
		
		return SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress)!
	}
}

public extension Reachability {
	@discardableResult
	func startNotifier() -> Self {
		guard !notifierRunning else { return self }
		
		let callback: SCNetworkReachabilityCallBack = { reachability, flags, info in
			guard let info = info else { return }
			let weakifiedReachability = Unmanaged<ReachabilityWeakifier>.fromOpaque(info).takeUnretainedValue()
			weakifiedReachability.reachability?.flags = flags
		}
		
		let weakifiedReachability = ReachabilityWeakifier(reachability: self)
		let opaqueWeakifiedReachability = Unmanaged<ReachabilityWeakifier>.passUnretained(weakifiedReachability).toOpaque()
		
		var context = SCNetworkReachabilityContext(
			version: 0,
			info: UnsafeMutableRawPointer(opaqueWeakifiedReachability),
			retain: { info in
				let unmanagedWeakifiedReachability = Unmanaged<ReachabilityWeakifier>.fromOpaque(info)
				_ = unmanagedWeakifiedReachability.retain()
				return UnsafeRawPointer(unmanagedWeakifiedReachability.toOpaque())
		},
			release: { info in
				let unmanagedWeakifiedReachability = Unmanaged<ReachabilityWeakifier>.fromOpaque(info)
				unmanagedWeakifiedReachability.release()
		},
			copyDescription: { info in
				let unmanagedWeakifiedReachability = Unmanaged<ReachabilityWeakifier>.fromOpaque(info)
				let weakifiedReachability = unmanagedWeakifiedReachability.takeUnretainedValue()
				let description = weakifiedReachability.reachability?.description ?? "nil"
				return Unmanaged.passRetained(description as CFString)
		}
		)
		
		if !SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
			stopNotifier()
			return self
		}
		
		if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef, reachabilitySerialQueue) {
			stopNotifier()
			return self
		}
		
		setReachabilityFlags()
		
		notifierRunning = true
		return self
	}
	
	func stopNotifier() {
		defer { notifierRunning = false }
		
		SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
		SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
	}
	
	var isOffline: Bool { return connection == .unavailable }
	
	var description: String {
		return flags?.description ?? "unavailable flags"
	}
}

extension Reachability {
	func setReachabilityFlags() {
		var flags = SCNetworkReachabilityFlags()
		if !SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) {
			self.stopNotifier()
		}
		
		self.flags = flags
	}
	
	
	func notifyReachabilityChanged() {
		for (_, callback) in self.reachabilityCallbacks {
			callback(self)
		}
		Notifications.reachabilityChanged.notify(self)
		if #available(OSX 10.13, iOS 13, watchOS 6, *) {
			objectChanged()
		}
	}
}

extension SCNetworkReachabilityFlags {
	typealias Connection = Reachability.Connection
	
	var connection: Connection {
		guard isReachableFlagSet else { return .unavailable }
		#if targetEnvironment(simulator)
			return .wifi
		#else
			var connection = Connection.unavailable
			
			if !isConnectionRequiredFlagSet {
				connection = .wifi
			}
			
			if isConnectionOnTrafficOrDemandFlagSet, !isInterventionRequiredFlagSet {
				connection = .wifi
			}
			
			if isOnWWANFlagSet {
				connection = .cellular
			}
			
			return connection
		#endif
	}
	
	var isOnWWANFlagSet: Bool {
		#if os(iOS)
			return contains(.isWWAN)
		#else
			return false
		#endif
	}
	var isReachableFlagSet: Bool {
		return contains(.reachable)
	}
	var isConnectionRequiredFlagSet: Bool {
		return contains(.connectionRequired)
	}
	var isInterventionRequiredFlagSet: Bool {
		return contains(.interventionRequired)
	}
	var isConnectionOnTrafficFlagSet: Bool {
		return contains(.connectionOnTraffic)
	}
	var isConnectionOnDemandFlagSet: Bool {
		return contains(.connectionOnDemand)
	}
	var isConnectionOnTrafficOrDemandFlagSet: Bool {
		return !intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
	}
	var isTransientConnectionFlagSet: Bool {
		return contains(.transientConnection)
	}
	var isLocalAddressFlagSet: Bool {
		return contains(.isLocalAddress)
	}
	var isDirectFlagSet: Bool {
		return contains(.isDirect)
	}
	var isConnectionRequiredAndTransientFlagSet: Bool {
		return intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
	}
	
	var description: String {
		let W = isOnWWANFlagSet ? "W" : "-"
		let R = isReachableFlagSet ? "R" : "-"
		let c = isConnectionRequiredFlagSet ? "c" : "-"
		let t = isTransientConnectionFlagSet ? "t" : "-"
		let i = isInterventionRequiredFlagSet ? "i" : "-"
		let C = isConnectionOnTrafficFlagSet ? "C" : "-"
		let D = isConnectionOnDemandFlagSet ? "D" : "-"
		let l = isLocalAddressFlagSet ? "l" : "-"
		let d = isDirectFlagSet ? "d" : "-"
		
		return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
	}
}

private class ReachabilityWeakifier {
	weak var reachability: Reachability?
	init(reachability: Reachability) {
		self.reachability = reachability
	}
}
#endif

