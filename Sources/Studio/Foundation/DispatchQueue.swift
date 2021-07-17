//
//  DispatchQueue.swift
//  
//
//  Created by Ben Gottlieb on 7/16/20.
//

import Foundation

extension DispatchQueue {
	static var semaphores: [String: DispatchSemaphore] = [:]
	
	/// Run a piece of code all by itself, ensuring it's isolated from other code, keyed by a namespace
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

	@inline(__always)  public static func onMain(_ block: @escaping () -> Void) {
		if Thread.isMainThread {
			block()
		} else {
			DispatchQueue.main.async(execute: block)
		}
	}
    
    public func async(after: TimeInterval, _ block: @escaping () -> Void) {
        asyncAfter(deadline: .now() + after, execute: block)
    }
}
