//
//  Observables.swift
//  
//
//  Created by Ben Gottlieb on 5/12/22.
//

import Foundation

public class NotificationWatcher: NSObject, ObservableObject {
	public init(_ name: Notification.Name, object: Any? = nil) {
		super.init()
		NotificationCenter.default.addObserver(forName: name, object: object, queue: .main) { note in
			self.objectWillChange.send()
		}
	}
}

public class PokeableObject: ObservableObject {
	public init() {
		
	}
	
	public func poke() {
		objectWillChange.send()
	}
}
