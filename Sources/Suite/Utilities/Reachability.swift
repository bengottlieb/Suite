import Network
import Foundation

@available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *)
public class Reachability: ObservableObject {
	public static let instance = Reachability()

	private let pathMonitor = NWPathMonitor()
	private var queue: DispatchQueue
	private var isMonitoring = false
	private var isStartingUp = true
	private var startupContinuation: CheckedContinuation<Bool, Never>?
	
	init(queue: DispatchQueue = .main) {
		self.queue = queue
		start()
	}

	public func setup() { }
	
	@discardableResult public func setupAndCheckForOnline() async -> Bool {
		if !isStartingUp || startupContinuation != nil { return !isOffline }
		
		return await withCheckedContinuation { continuation in
			self.startupContinuation = continuation
		}
	}
	
	func start() {
		if isMonitoring { return }
		pathMonitor.pathUpdateHandler = { [weak self] path in
			self?.objectWillChange.sendOnMain()
			Notifications.reachabilityChanged.notify()
		}
		isMonitoring = true
		objectWillChange.sendOnMain()
		DispatchQueue.main.async(after: 0.25) {
			self.objectWillChange.send()
			self.isStartingUp = false
			self.startupContinuation?.resume(returning: !self.isOffline)
			self.startupContinuation = nil
		}
		pathMonitor.start(queue: queue)
	}
	
	func stop() {
		if !isMonitoring { return }
		isMonitoring = false
		pathMonitor.cancel()
	}
}

public extension Reachability {
	struct Notifications {
		public static let reachabilityChanged = Notification.Name("Reachability.Notifications.reachabilityChanged")
	}
	
	var connection: Connection {
		if !isMonitoring || isStartingUp { return .other }
		let path = pathMonitor.currentPath
		if path.usesInterfaceType(.wiredEthernet) {
			 return .ethernet
		} else if path.usesInterfaceType(.wifi) {
			 return .wifi
		} else if path.usesInterfaceType(.cellular) {
			 return .cellular
		} else if path.usesInterfaceType(.loopback) {
			 return .loopback
		} else if path.usesInterfaceType(.other) {
			 return .other
		} else {
			 return .unavailable
		}
	}
	var isOffline: Bool { return connection == .unavailable }

	enum Connection: CustomStringConvertible {
		case none, unavailable, wifi, cellular, ethernet, loopback, other
		public var description: String {
			switch self {
			case .cellular: return NSLocalizedString("Cellular", comment: "Cellular")
			case .wifi: return NSLocalizedString("WiFi", comment: "WiFi")
			case .ethernet: return NSLocalizedString("Ethernet", comment: "Ethernet")
			case .loopback: return NSLocalizedString("Loopback", comment: "Loopback")
			case .other: return NSLocalizedString("Other networking", comment: "Other networking")
			case .unavailable: return NSLocalizedString("No Connection", comment: "No Connection")
			case .none: return NSLocalizedString("None", comment: "None")
			}
		}
	}

}
