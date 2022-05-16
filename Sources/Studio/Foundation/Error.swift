//
//  Error.swift
//  
//
//  Created by Ben Gottlieb on 8/1/21.
//

import Foundation

public typealias ErrorCallback = (Error?) -> Void

public protocol DisplayableError: Error {
	var errorTitle: String { get }
	var errorMessage: String { get }
}
