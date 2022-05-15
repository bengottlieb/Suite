//
//  ReadyFlag.swift
//  
//
//  Created by Ben Gottlieb on 5/14/22.
//

import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct ReadyFlag {
	public func waitForReady() async {
		if await storage.value { return }
		let _: Bool = await withUnsafeContinuation { continuation in
			Task { await storage.append(continuation) }
		}
	}
	
	public init() {
	}
	
	public func makeReady() { set(true) }
	public func set(_ newValue: Bool) { Task { await storage.set(newValue) } }

	let storage = Storage()
	
	actor Storage {
		var value = false
		var continuations: [UnsafeContinuation<Bool, Never>] = []
		
		func append(_ continuation: UnsafeContinuation<Bool, Never>) {
			continuations.append(continuation)
		}
		
		func set(_ newValue: Bool) {
			if !newValue { return }
			value = newValue
			let continues = continuations
			continuations = []
			for con in continues { con.resume(returning: true) }
		}
	}
}
