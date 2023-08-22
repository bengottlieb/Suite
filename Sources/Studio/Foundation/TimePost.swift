//
//  TimePost.swift
//
//
//  Created by Ben Gottlieb on 8/22/23.
//

import Foundation

public class TimePost: @unchecked Sendable {
	static var registered: [String: TimePost] = [:]
	static var enabled = true
	
	public var startTime = Date()
	public var last: Date?
	var name: String?
	
	public static func post(_ name: String) -> TimePost {
		if let current = registered[name] { return current }
		let new = TimePost(name)
		registered[name] = new
		return new
	}
	
	private init(_ name: String) {
		self.name = name
	}
	
	init() {
		
	}
	
	public func start(_ message: String? = nil) {
		if !Self.enabled { return }

		startTime = Date()
		print("💈 Starting \(message ?? name ?? "")")
	}
	
	public func mark(_ message: String) {
		if !Self.enabled { return }

		let time = Date()
		let previous = last ?? startTime
		let elapsed = time.timeIntervalSince(previous)
		self.last = time
		print("💈 \(message) [\(elapsed) sec]")
	}
	
	public func end(_ message: String? = nil) {
		if !Self.enabled { return }
		let elapsed = Date().timeIntervalSince(startTime)
		print("💈 \(message ?? name ?? "Total time") [\(elapsed) sec]")
		if let name { Self.registered.removeValue(forKey: name) }
	}
	
}
