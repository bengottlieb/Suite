//
//  Publisher.swift
//  
//
//  Created by Ben Gottlieb on 8/1/20.
//

#if canImport(Combine)
import Combine

@available(iOS 13.0, *)
public extension ObservableObjectPublisher {
	func sendOnMainThread() {
		if Thread.isMainThread {
			self.send()
		} else {
			DispatchQueue.main.async { self.send() }
		}
	}
}


#endif
