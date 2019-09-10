
//
//  Process.swift
//  Suite
//
//  Created by Ben Gottlieb on 9/10/19.
//  Copyright (c) 2019 Stand Alone, Inc. All rights reserved.
//

import Foundation
 
#if os(OSX)
	public extension Process {
		convenience init (path: String, arguments args: [String]) {
			self.init()
			launchPath = path
			arguments = args
		}

		func stringValue(timeout: TimeInterval = 0) -> String? {
			if self.standardOutput as? Pipe == nil { _ = self.run(timeout: timeout) }

			if let fileHandle = (self.standardOutput as? Pipe)?.fileHandleForReading {
				let data = fileHandle.readDataToEndOfFile()
				let result = String(data: data, encoding: String.Encoding.ascii)
				return result
			}
			return nil
		}
		
		func errorValue(timeout: TimeInterval = 0) -> String? {
			if self.standardError as? Pipe == nil { _ = self.run(timeout: timeout) }
			
			if let fileHandle = (self.standardError as? Pipe)?.fileHandleForReading {
				let data = fileHandle.readDataToEndOfFile()
				let result = String(data: data, encoding: String.Encoding.ascii)
				return result
			}
			
			return nil
		}
		
		func dataValue(timeout: TimeInterval = 0) -> Data? {
			if self.standardOutput as? Pipe == nil { _ = self.run(timeout: timeout) }

			if let fileHandle = (self.standardOutput as? Pipe)?.fileHandleForReading {
				let data = fileHandle.readDataToEndOfFile()
				return data
			}
			return nil
		}
		
		func run(timeout: TimeInterval = 0) -> Int32 {
			self.standardOutput = Pipe()
			self.standardError = Pipe()
			
			if timeout > 0 {
				self.terminationHandler = { task in
					CFRunLoopWakeUp(RunLoop.current.getCFRunLoop())
					return
				}
				self.launch()
				
				let cutoff = Date(timeIntervalSinceNow: timeout)
				
				while (self.isRunning) {
					RunLoop.current.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 0.01))
					if cutoff < Date() {
						self.terminate()
						return 9
					}
				}
			} else {
				self.launch()
				self.waitUntilExit()
			}

			return self.terminationStatus
		}

		
	}


	public extension Gestalt {
		static var isAppSandboxed: Bool {
			// "codesign -dvvv --entitlements :- /path/to/executable"
			
			guard let path = Bundle.main.executablePath else { return true }
			let task = Process(path: "/usr/bin/codesign", arguments: ["-dvvv", "--entitlements", ":-", path])
			if let data = task.dataValue(), let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil), let info = plist as? [String: Any] {
				if let isSandbox = info["com.apple.security.app-sandbox"] as? Bool {
					return isSandbox
				} else if let sandbox = info["com.apple.security.app-sandbox"] as? Int {
					return sandbox == 1
				}
			}
			
			return false
		}
	}
#endif
