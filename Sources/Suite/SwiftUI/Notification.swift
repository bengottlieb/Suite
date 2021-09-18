//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 9/18/21.
//

import Foundation

#if canImport(Combine)
import Combine
@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension Notification.Name {
	func publisher(object: AnyObject? = nil) -> NotificationCenter.Publisher {
		NotificationCenter.default.publisher(for: self, object: object)
	}
}
#endif

