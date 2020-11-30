//
//  SwiftUIView.swift
//  
//
//  Created by ben on 11/30/20.
//

#if canImport(Combine)
import Combine

@available(iOS 13.0, watchOS 6.0, OSX 10.15, *)
public enum HTTPError: Error {
	case nonHTTPResponse
	case requestFailed(Int, Data?)
	case redirectError(Int, Data?)
	case serverError(Int)
	case unknownError(Int)
	case networkError(Error)
	case decodingError(DecodingError)
	
	public var isRetriable: Bool {
		switch self {
		case .redirectError: return false
		case .unknownError: return false
		case .decodingError: return false
		case .requestFailed(let status, _):
			let timeoutStatus = 408
			let rateLimitStatus = 429
			return status == timeoutStatus || status == rateLimitStatus
			
		case .serverError, .networkError, .nonHTTPResponse:
			return true
		}
	}
}

@available(iOS 13.0, watchOS 6.0, OSX 10.15, *)
public extension Publisher where Output == (data: Data, response: URLResponse) {
	func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPError> {
		tryMap { data, response in
			guard let http = response as? HTTPURLResponse else { throw HTTPError.nonHTTPResponse }
			return (data, http)
		}
		.mapError { error in
			if error is HTTPError {
				return error as? HTTPError ?? HTTPError.unknownError(0)
			} else {
				return HTTPError.networkError(error)
			}
		}
		.eraseToAnyPublisher()
	}
}

@available(iOS 13.0, watchOS 6.0, OSX 10.15, *)
public extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == HTTPError {
	func responseData() -> AnyPublisher<Data, HTTPError> {
		tryMap { data, response in
			switch response.statusCode {
			case 0...199: return data				// informational, rarely seen
			case 200...299: return data				// success, of some sort
			case 300...399: throw HTTPError.redirectError(response.statusCode, data)
			case 400...499: throw HTTPError.requestFailed(response.statusCode, data)
			case 500...599: throw HTTPError.serverError(response.statusCode)
			default: throw HTTPError.unknownError(response.statusCode)
			}
		}
		.mapError { $0 as! HTTPError }
		.eraseToAnyPublisher()
	}
}

@available(iOS 13.0, watchOS 6.0, OSX 10.15, *)
public extension Publisher where Output == Data, Failure == HTTPError {
	func decoding<Item, Coder>(type: Item.Type, decoder: Coder) -> AnyPublisher<Item, HTTPError> where Item: Decodable, Coder: TopLevelDecoder, Self.Output == Coder.Input {
		decode(type: type, decoder: decoder)
			.mapError { error in
				if error is DecodingError {
					return HTTPError.decodingError(error as! DecodingError)
				} else {
					return error as! HTTPError			// we're already restricting errors to HTTPError
				}
			}
			.eraseToAnyPublisher()
	}
}

#endif
