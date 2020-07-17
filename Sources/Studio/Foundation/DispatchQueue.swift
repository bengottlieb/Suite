//
//  DispatchQueue.swift
//  
//
//  Created by Ben Gottlieb on 7/16/20.
//

import Foundation

extension DispatchQueue {
	static var semaphores: [String: DispatchSemaphore] = [:]
	
	public static func isolated(_ namespace: String, block: () -> Void) {
		var semaphore: DispatchSemaphore!
		
		if let existing = semaphores[namespace] {
			semaphore = existing
		} else {
			semaphore = DispatchSemaphore(value: 1)
			semaphores[namespace] = semaphore
		}
		
		semaphore.wait()
		block()
		semaphore.signal()
	}
}
