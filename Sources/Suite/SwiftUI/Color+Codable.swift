//
//  Color+Codable.swift
//  
//
//  Created by Ben Gottlieb on 5/9/23.
//

import SwiftUI
import Studio

@available(iOS 14.0, tvOS 13, macOS 11, watchOS 7, *)
extension Color: Codable {
	enum ColorDecodeError: Error { case unableToExtractColor }
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		
		let hex = try container.decode(String.self)
		if let color = Color(hex: hex) {
			self = color
		} else {
			throw ColorDecodeError.unableToExtractColor
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		
		if let hex = self.hex {
			try container.encode(hex)
		}
	}
}
