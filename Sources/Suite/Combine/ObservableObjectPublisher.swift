//
//  File.swift
//  
//
//  Created by ben on 8/26/20.
//


#if canImport(Combine)

import Foundation
import Combine

@available(iOS 13.0, macOS 10.15, *)
public extension ObservableObjectPublisher {
	func sendOnMain() {
		DispatchQueue.onMain { self.send() }
	}
}

#endif
