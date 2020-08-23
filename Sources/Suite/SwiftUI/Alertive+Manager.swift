//
//  Alertive+Manager.swift
//  
//
//  Created by ben on 8/13/20.
//

#if canImport(Combine)
import SwiftUI
import Combine

@available(OSX 10.15, iOS 13.0, *)
extension Alertive {
	public static let manager = Manager()
	
	public class Manager: ObservableObject {
		fileprivate init() {
			
		}
		
		@Published var pendingAlerts: [PendingAlert] = []
		
		public func show(title: String? = nil, body: String? = nil, tag: String? = nil, buttons: [Alertive.Button]) {
			guard title?.isEmpty == false || body?.isEmpty == false || buttons.isEmpty == false else { return }
			
			let alert = PendingAlert(title: title, body: body, tag: tag, buttons: buttons)
			DispatchQueue.main.async {
				if self.pendingAlerts.isEmpty {
					withAnimation() {
						self.pendingAlerts.append(alert)
					}
				} else {
					self.pendingAlerts.append(alert)
				}
			}
		}
		
		func remove(_ pending: PendingAlert) {
			if let index = self.pendingAlerts.firstIndex(of: pending) {
				_ = withAnimation() {
					self.pendingAlerts.remove(at: index)
				}
			}
		}
		
		struct PendingAlert: Identifiable, Equatable {
			let id: String = UUID().uuidString
			let title: String?
			let body: String?
			let tag: String?
			let buttons: [Alertive.Button]
			
			func buttonPressed() {
				Alertive.manager.remove(self)
			}
			
			static func ==(lhs: PendingAlert, rhs: PendingAlert) -> Bool { lhs.id == rhs.id }
		}
	}
	
	public struct Button: Identifiable {
		public enum Kind { case normal, cancel, destructive }
		public let id: String = UUID().uuidString
		public let label: String
		public let kind: Kind
		public let action: (() -> Void)?
		
		func pressed() {
			self.action?()
		}
		
		public static func `default`(_ label: String, action: (() -> Void)? = {}) -> Button {
			Button(label: label, kind: .normal, action: action)
		}
		
		public static func cancel(_ label: String = .Cancel, action: (() -> Void)? = {}) -> Button {
			Button(label: label, kind: .cancel, action: action)
		}
		
		public static func destructive(_ label: String, _ action: (() -> Void)? = {}) -> Button {
			Button(label: label, kind: .destructive, action: action)
		}

	}
}





@available(OSX 10.15, iOS 13.0, *)
public struct AlertiveKey: EnvironmentKey {
	public static let defaultValue: Alertive.Manager = Alertive.manager
}

@available(OSX 10.15, iOS 13.0, *)
extension EnvironmentValues {
	var alertive: Alertive.Manager {
		get { return self[AlertiveKey.self] }
		set { self[AlertiveKey.self] = newValue }
	}
}

#endif
