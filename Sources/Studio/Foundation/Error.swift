//
//  Error.swift
//  
//
//  Created by Ben Gottlieb on 8/1/21.
//

import Foundation

public typealias ErrorCallback = (Error?) -> Void

public extension Error {
	 var isOffline: Bool {
		  if let httpError = self as? HTTPError, httpError.isOffline { return true }
		  return (self as NSError).code == -1009
	 }
}

public extension Array where Element == Error {
	 var isOffline: Bool {
		  !isEmpty && self.count == self.filter { $0.isOffline }.count
	 }
}

public protocol DisplayableError: Error {
	var errorTitle: String { get }
	var errorMessage: String { get }
}
