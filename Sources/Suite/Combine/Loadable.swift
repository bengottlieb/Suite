//
//  Loadable.swift
//  
//
//  Created by ben on 11/26/20.
//

import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public protocol Loadable: ObservableObject {
	associatedtype Output
	var state: LoadingState<Output> { get }
	func load()
}
