//
//  Decoding.swift
//  
//
//  Created by Ben Gottlieb on 12/5/21.
//

import Foundation

public extension KeyedDecodingContainer {
	func decode<T: Decodable>(_ key: Key, as type: T.Type = T.self) throws -> T {
		try self.decode(T.self, forKey: key)
	}
	
	func decodeIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) throws -> T? {
		try decodeIfPresent(T.self, forKey: key)
	}
}

public struct SafeDecodable<Base: Decodable>: Decodable {
	public let value: Base?
	public let error: Error?
	
	public init(from decoder: Decoder) throws {
		do {
			let container = try decoder.singleValueContainer()
			self.value = try container.decode(Base.self)
			self.error = nil
		} catch {
			self.value = nil
			self.error = error
		}
	}
}

public struct SafeResult<Kind: Decodable> {
	public let array: [Kind]
	public let errors: [Error]
}

public extension JSONDecoder {
	func safelyDecodeArray<Kind: Decodable>(of element: Kind, from data: Data) -> SafeResult<Kind> {
		do {
			let results = try self.decode([SafeDecodable<Kind>].self, from: data)
			
			return SafeResult(array: results.compactMap { $0.value }, errors: results.compactMap { $0.error })
		} catch {
			return SafeResult<Kind>(array: [], errors: [error])
		}
	}
}

extension JSONDecoder.DateDecodingStrategy {
    var encodingStrategy: JSONEncoder.DateEncodingStrategy {
        switch self {
        case .deferredToDate: return .deferredToDate
        case .secondsSince1970: return .secondsSince1970
        case .millisecondsSince1970: return .millisecondsSince1970
        case .iso8601: return .iso8601
        default: return .default
        }
    }
}

extension JSONEncoder.DateEncodingStrategy {
    var decodingStrategy: JSONDecoder.DateDecodingStrategy {
        switch self {
        case .deferredToDate: return .deferredToDate
        case .secondsSince1970: return .secondsSince1970
        case .millisecondsSince1970: return .millisecondsSince1970
        case .iso8601: return .iso8601
        default: return .default
        }
    }
}
