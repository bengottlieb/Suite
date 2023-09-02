//
//  Result.swift
//  
//
//  Created by Ben Gottlieb on 5/30/20.
//

import Foundation

extension Result {
	public var isSuccess: Bool {
		switch self {
		case .failure(_): return false
		case .success(_): return true
		}
	}
}
