//
//  Alertive+Manager.swift
//  
//
//  Created by ben on 8/13/20.
//

#if canImport(Combine)
import SwiftUI
import Combine

@available(OSX 11, iOS 14.0, *)
extension Alertive {
	public static let manager = Manager()
	
	public class Manager: ObservableObject {
		fileprivate init() {
			
		}
		
		@Published var pendingAlerts: [PendingAlert] = []
		
		public func show(title: Text? = nil, message: Text? = nil, tag: String? = nil, buttons: [Alertive.Button]) {
			guard title != nil || message != nil || buttons.isEmpty == false else { return }
			
			let alert = PendingAlert(title: title, message: message, tag: tag, buttons: buttons)
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
	}
	
	public struct PendingAlert: Identifiable, Equatable {
		public let id = UUID()
		var tag: String?
		var title: Text?
		var message: Text?
		let buttons: [Alertive.Button]
		
		func buttonPressed() {
			Alertive.manager.remove(self)
		}
		
		public init(title: Text? = nil, message: Text? = nil, tag: String? = nil, buttons: [Alertive.Button]) {
			self.title = title
			self.message = message
			self.tag = tag
			self.buttons = buttons
		}

		public init(title: Text? = nil, message: Text? = nil, tag: String? = nil, primaryButton: Alertive.Button? = nil, secondaryButton: Alertive.Button? = nil, dismissButton: Alertive.Button? = nil) {
			self.title = title
			self.message = message
			self.tag = tag
			self.buttons = [primaryButton, secondaryButton, dismissButton].compactMap { $0 }
		}

		public static func ==(lhs: PendingAlert, rhs: PendingAlert) -> Bool { lhs.id == rhs.id }
	}

	public struct Button: Identifiable {
		public enum Kind { case normal, cancel, destructive }
		public let id: String = UUID().uuidString
		public let label: Text
		public let kind: Kind
		public let action: (() -> Void)?
		
		func pressed() {
			self.action?()
		}
		
		public static func `default`(_ label: Text, action: (() -> Void)? = {}) -> Button {
			Button(label: label, kind: .normal, action: action)
		}
		
		public static func cancel(_ label: Text = Text(String.Cancel), action: (() -> Void)? = {}) -> Button {
			Button(label: label, kind: .cancel, action: action)
		}
		
		public static func destructive(_ label: Text, _ action: (() -> Void)? = {}) -> Button {
			Button(label: label, kind: .destructive, action: action)
		}

	}
}





@available(OSX 11, iOS 14.0, *)
public struct AlertiveKey: EnvironmentKey {
	public static let defaultValue: Alertive.Manager = Alertive.manager
}

@available(OSX 11, iOS 14.0, *)
extension EnvironmentValues {
	var alertive: Alertive.Manager {
		get { return self[AlertiveKey.self] }
		set { self[AlertiveKey.self] = newValue }
	}
}

#endif
