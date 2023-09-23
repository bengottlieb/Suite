//
//  RawCodable.swift
//  
//
//  Created by Ben Gottlieb on 9/22/23.
//

import Foundation

public protocol RawCodable: RawRepresentable, Codable, Identifiable where RawValue: Codable {
	
}

extension RawCodable {
	public var id: RawValue { rawValue }
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(self.rawValue)
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let raw = try container.decode(RawValue.self)
		if let value = Self(rawValue: raw) {
			self = value
		} else {
			throw NSError()
		}
	}
}
