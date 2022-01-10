//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 1/9/22.
//

import Foundation

public extension MainActor {
	static func runNow(_ block: @escaping () -> Void) {
		Task { await MainActor.run { block() }}
	}
}
