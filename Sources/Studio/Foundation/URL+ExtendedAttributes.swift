//
//  URL+ExtendedAttributes.swift
//  
//
//  Created by Ben Gottlieb on 11/15/22.
//

import Foundation

public enum ExtendedAttributeError: Error {
	case notAFile
	case noAttributeFound
	case posixError(Int32)
}

public extension URL {
	func extendedAttribute(for name: String) throws -> Data  {
		guard isFileURL else { throw ExtendedAttributeError.notAFile }
		let data = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> Data in
			
			// Determine attribute size:
			let length = getxattr(fileSystemPath, name, nil, 0, 0, 0)
			guard length >= 0 else { throw ExtendedAttributeError.noAttributeFound }
			
			// Create buffer with required size:
			var data = Data(count: length)
			
			// Retrieve attribute:
			let result = data.withUnsafeMutableBytes { [count = data.count] data in
				getxattr(fileSystemPath, name, data.baseAddress, count, 0, 0)
			}
			guard result >= 0 else { throw ExtendedAttributeError.posixError(errno) }
			return data
		}
		return data
	}
	
	func setExtendedAttribute(data: Data, for name: String) throws {
		guard isFileURL else { throw ExtendedAttributeError.notAFile }
		try self.withUnsafeFileSystemRepresentation { fileSystemPath in
			let result = data.withUnsafeBytes { bytes in
				setxattr(fileSystemPath, name, bytes.baseAddress, data.count, 0, 0)
			}
			guard result >= 0 else { throw ExtendedAttributeError.posixError(errno) }
		}
	}
	
	func removeExtendedAttribute(forName name: String) throws {
		guard isFileURL else { throw ExtendedAttributeError.notAFile }

		try self.withUnsafeFileSystemRepresentation { fileSystemPath in
			let result = removexattr(fileSystemPath, name, 0)
			guard result >= 0 else { throw ExtendedAttributeError.posixError(errno) }
		}
	}
	
	var allExtendedAttributes: [String: Data] {
		get throws {
			let all = try allExtendedAttributeNames
			
			var results: [String: Data] = [:]
			
			for name in all {
				if let data = try? extendedAttribute(for: name) {
					results[name] = data
				}
			}
			
			return results
		}
	}
	
	var allExtendedAttributeNames: [String] {
		get throws {
			guard isFileURL else { throw ExtendedAttributeError.notAFile }
			
			let all = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> [String] in
				let length = listxattr(fileSystemPath, nil, 0, 0)
				guard length >= 0 else { throw ExtendedAttributeError.posixError(errno) }
				
				var namebuf = Array<CChar>(repeating: 0, count: length)
				
				let result = listxattr(fileSystemPath, &namebuf, namebuf.count, 0)
				guard result >= 0 else { throw ExtendedAttributeError.posixError(errno) }
				
				let list = namebuf.split(separator: 0).compactMap { buffer in
					buffer.withUnsafeBufferPointer { pointer in
						pointer.withMemoryRebound(to: UInt8.self) { bytes in
							String(bytes: bytes, encoding: .utf8)
						}
					}
				}
				return list
			}
			return all
		}
	}
}
