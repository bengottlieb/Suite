//
//  ObservableObjectPublisher.swift
//  
//
//  Created by ben on 8/26/20.
//


#if canImport(Combine)

import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
struct ObserverMonitor<Pub: ObservableObjectPublisher, Content: View>: View {
	let target: Pub
	let content: Content
	let message: String?
	var cancellable: AnyCancellable?

	init(_ target: Pub, content: Content, message: String? = nil) {
		self.target = target
		self.content = content
		self.message = message
		cancellable = target.eraseToAnyPublisher().sink { item in Logger.instance.log("\(item) changed in \(message ?? String(describing: content))")}
	}

	var body: some View {
		content
	}
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
extension View {
	public func monitor(_ target: ObservableObjectPublisher, _ message: String? = nil) -> some View {
		ObserverMonitor(target, content: self, message: message)
	}
	
}


@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public extension ObservableObjectPublisher {
	func sendOnMain() {
		DispatchQueue.onMain { self.send() }
	}
	
	func monitor(message: String) {
		eraseToAnyPublisher()
			.onSuccess() { _ in logg(message) }
	}
}

#endif
