//
//  Logger.swift
//  
//
//  Created by ben on 12/4/19.
//

import Foundation
import CoreData

public func log(_ msg: @autoclosure () -> String, _ level: Logger.Level = .quiet) { Logger.instance.log(msg(), level: level) }
public func dlog(_ msg: @autoclosure () -> String, _ level: Logger.Level = .mild) { Logger.instance.log(msg(), level: level) }
public func elog(_ error: Error, _ msg: @autoclosure () -> String, _ level: Logger.Level = .mild) { Logger.instance.log(error: error, msg(), level: .quiet) }
public func dlog(_ something: Any, _ level: Logger.Level = .mild) { Logger.instance.log("\(something)", level: level) }

public class Logger {
	static public let instance = Logger()
	
	public enum Level: Int, Comparable {
		case off, quiet, mild, loud, verbose
		public static func <(lhs: Level, rhs: Level) -> Bool { return lhs.rawValue < rhs.rawValue }
	}
	
	public var level: Level = {
		if Gestalt.isProductionBuild { return .off }
		if Gestalt.isAttachedToDebugger { return .mild }
		return .quiet
	}()
	
	public func log(_ msg: @autoclosure () -> String, level: Level = .mild) {
		if level > self.level { return }
		print(msg())
	}
	
	public func log(error: Error, _ msg: @autoclosure () -> String, level: Level = .mild) {
		if level > self.level { return }
		let message = "⚠️ \(msg()) \(error)"
		print(message)
	}
}

public extension NSManagedObject {
	func logObject(_ level: Logger.Level = .mild) { dlog("\(self)", level) }
}
