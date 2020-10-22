//
//  File.swift
//  
//
//  Created by ben on 8/26/20.
//


#if canImport(Combine)

import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public extension ObservableObjectPublisher {
	func sendOnMain() {
		DispatchQueue.onMain { self.send() }
	}
}

#endif
