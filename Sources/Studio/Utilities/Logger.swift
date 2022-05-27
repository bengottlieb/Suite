//
//  Logger.swift
//  
//
//  Created by ben on 12/4/19.
//

import Foundation
import CoreData

public func logg(_ msg: @escaping @autoclosure () -> String, _ level: Logger.Level = .mild) { Logger.instance.log(msg(), level: level) }
public func logg<What: AnyObject>(raw: What, _ level: Logger.Level = .mild) { Logger.instance.log(raw: raw, level) }
public func logg(_ special: Logger.Special, _ level: Logger.Level = .mild) { Logger.instance.log(special, level: level) }
public func dlogg(_ msg: @escaping @autoclosure () -> String, _ level: Logger.Level = .mild) { Logger.instance.log(msg(), level: level) }
public func logg(error: Error?, _ msg: @escaping @autoclosure () -> String, _ level: Logger.Level = .mild) { Logger.instance.log(error: error, msg(), level: level) }
public func dlogg(_ something: Any, _ level: Logger.Level = .mild) { Logger.instance.log("\(something)", level: level) }
public func logg<T>(result: Result<T, Error>, _ msg: @escaping @autoclosure () -> String) {
	switch result {
	case .failure(let error): logg(error: error, msg())
	default: break
	}
}

#if canImport(Combine)
import Combine
@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public func logg<Failure>(completion: Subscribers.Completion<Failure>, _ msg: @escaping @autoclosure () -> String) {
	switch completion {
	case .failure(let error): logg(error: error, msg())
	default: break
	}
}
#endif

public class Logger {
	static public let instance = Logger()
	
	private init() { }
	
	private var serializer = DispatchQueue(label: "logger", qos: .userInitiated)
	public var fileURL: URL?
	var logFileExists = false
	public var showTimestamps = true { didSet { self.timestampStart = Date() }}
	public var timestampStart = Date()
	public var logErrors: Bool { level > .mild }
	var redirected: ((String) -> Void)?
	
	public func log(to url: URL, clearingFirst: Bool = true) {
		fileURL = url
		
		try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
		if clearingFirst {
			try? FileManager.default.removeItem(at: url)
		} else {
			logFileExists = FileManager.default.fileExists(at: url)
		}
	}
	
	public func redirect(showingTimestamps: Bool = false, to block: ((String) -> Void)?) {
		showTimestamps = showingTimestamps
		redirected = block
	}
	
	public enum Special { case `break` }
	public enum Level: Int, Comparable {
		case off, quiet, mild, loud, verbose
		public static func <(lhs: Level, rhs: Level) -> Bool { return lhs.rawValue < rhs.rawValue }
	}
	
	func output(_ string: String) {
		if let redirect = redirected {
			redirect(string)
			return
		}
		print(string)
		
		if let url = fileURL, let data = string.data(using: .utf8) {
			write(data, to: url)
		}
	}
	
	func write(_ data: Data, to url: URL) {
		do {
			if logFileExists {
				let linefeed = "\n".data(using: .utf8)!
				
				let file = try FileHandle(forUpdating: url)
				if #available(iOS 13.4, watchOS 6.2, macOS 10.15.4, *) {
					try file.seekToEnd()
				} else {
					file.seekToEndOfFile()
				}
				file.write(data)
				file.write(linefeed)
				file.closeFile()
			} else {
				try data.write(to: url)
				logFileExists = true
				write("".data(using: .utf8)!, to: url)
			}
		} catch {
			if (error as NSError).code == 4 {
				logFileExists = false
			} else {
				print("Failed to log to file: \(error)")
			}
		}
	}
	
	public var level: Level = {
        if let cmdLineArg = CommandLine.string(for: "logger")?.lowercased() {
            switch cmdLineArg {
            case "v": return .verbose
            case "q": return .quiet
            default: break
            }
            
        }
		if Gestalt.distribution == .appStore { return .off }
		if Gestalt.isAttachedToDebugger { return Gestalt.isOnSimulator ? .loud : .mild }
		return .quiet
	}()
	
	public func log(_ special: Special, level: Logger.Level = .mild) {
		if level > self.level { return }
		switch special {
		case .break: output("\n")
		}
	}
	
	public func log<What: AnyObject>(raw: What, _ level: Logger.Level = .mild) {
        self.log("\(address(of: raw))", level: level)
	}
	
	public func log(_ msg: @escaping @autoclosure () -> String, level: Level = .mild) {
		serializer.async {
			if level > self.level { return }
			var message = msg()
			
			if self.showTimestamps { message = String(format: "• %.04f - ", Date().timeIntervalSince(self.timestampStart)) + message }
			self.output(message)
		}
	}
	
	public func log(error: Error?, _ msg: @escaping @autoclosure () -> String, level: Level = .mild) {
		guard level <= self.level, let err = error else { return }
		let message = "⚠️ \(msg()) \(err) \n\(err.localizedDescription)\n\n"
		output(message)
	}
}

public extension NSManagedObject {
	func logObject(_ level: Logger.Level = .mild) { dlogg("\(self)", level) }
}

public func  address(of obj: AnyObject) -> String { "\(Unmanaged.passUnretained(obj).toOpaque())" }
