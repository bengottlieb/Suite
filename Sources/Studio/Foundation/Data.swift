//
//  Data.swift
//  
//
//  Created by ben on 11/10/19.
//

import Foundation

public extension Data {
	init?(hexString hex: String) {
		// Convert 0 ... 9, a ... f, A ...F to their decimal value,
		// return nil for all other input characters
		func decodeNibble(_ u: UInt16) -> UInt8? {
			switch(u) {
			case 0x30 ... 0x39: return UInt8(u - 0x30)
			case 0x41 ... 0x46: return UInt8(u - 0x41 + 10)
			case 0x61 ... 0x66: return UInt8(u - 0x61 + 10)
			default: return nil
			}
		}
		
		let utf16 = hex.utf16
		var count = 0
		var byteArray = Array<UInt8>(repeating: 0, count: hex.count / 2)

		var i = utf16.startIndex
		let endIndex = utf16.endIndex
		
		while i != endIndex {
			guard
				let hi = decodeNibble(utf16[i]),
				let nextNibble = utf16.index(i, offsetBy: 1, limitedBy: endIndex),
				nextNibble < endIndex,
				let lo = decodeNibble(utf16[nextNibble])
			else {
				return nil
			}
			byteArray[count] = hi << 4 + lo
			count += 1
			guard let next = utf16.index(i, offsetBy: 2, limitedBy: endIndex) else { break }
			i = next
		}
		self.init(bytes: byteArray, count: count)
	}
	
	var json: Any? {
		try? JSONSerialization.jsonObject(with: self, options: [])
	}

	var jsonDictionary: JSONDictionary? {
		if let json = try? JSONSerialization.jsonObject(with: self, options: []) as? JSONDictionary { return json }
		
		var format: PropertyListSerialization.PropertyListFormat = .binary
		guard let result = try? PropertyListSerialization.propertyList(from: self, format: &format) else { return nil }
		
		return result as? JSONDictionary
	}
	
	func jsonObject<ObjectType: Codable>(decoder: JSONDecoder = JSONDecoder.default) throws -> ObjectType {
		try ObjectType.loadJSON(data: self, using: decoder)
	}

	@discardableResult
	func debug_save(to name: String) -> URL! {
		let url = FileManager.documentsDirectory.appendingPathComponent(name + ".dat")
		do {
			try self.write(to: url)
			return url
		} catch {
			Studio.logg(error: error, "Writing data to \(url)")
			return nil
		}
	}
	
	
	var hexString: String { map { String(format: "%02.2hhx", $0) }.joined() }
	
}

public extension Data {
	enum DataReadError: Error { case tooShort }
	func peek<DataStructure>(type: DataStructure.Type) throws -> DataStructure {
		let size = MemoryLayout<DataStructure>.size
		if count < size { throw DataReadError.tooShort }
		
		return withUnsafeBytes { bytes in
			return bytes.load(as: DataStructure.self)
		}
	}
	
	mutating func consume<DataStructure>(type: DataStructure.Type) throws -> DataStructure {
		let size = MemoryLayout<DataStructure>.size
		let stride = MemoryLayout<DataStructure>.stride
		if count < size { throw DataReadError.tooShort }

		let result = withUnsafeBytes { bytes in
			return bytes.load(as: DataStructure.self)
		}
		
		self = self.dropFirst(stride)
		
		return result
	}
	
	mutating func consume(bytes size: Int) throws -> Data {
		if count < size { throw DataReadError.tooShort }
		let result = prefix(size)
		self = self.dropFirst(size)
		
		return result
	}
}

