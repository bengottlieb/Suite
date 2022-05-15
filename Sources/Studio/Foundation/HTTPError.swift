//
//  HTTPError.swift
//  
//
//  Created by Ben Gottlieb on 3/1/21.
//

import Foundation

extension Optional where Wrapped == URL {
	public func absoluteString(replacement: String? = "Missing URL") -> String { self?.absoluteString ?? replacement ?? "" }
}

public enum HTTPError: Error, LocalizedError {
    case nonHTTPResponse(URL?, Data)
    case offline
	 case other(Error?)
	 case message(String?)
    case requestFailed(URL?, Int, Data)
    case redirectError(URL?, Int, Data)
    case serverError(URL?, Int, Data)
    case unknownError(URL?, Int, Data?)
    case networkError(URL?, Error)
    case decodingError(URL?, DecodingError)
	 case unreachableError

	public init(_ url: URL?, _ error: Error) {
		if let err = error as? HTTPError {
			self = err
		} else if let decode = error as? DecodingError {
			self = .decodingError(url, decode)
		} else {
			self = .networkError(url, error)
		}
	}
	public var isOffline: Bool {
		 switch self {
		 case .offline: return true
		 default: return false
		 }
	}

	public var isServerError: Bool {
		 switch self {
		 case .serverError: return true
		 default: return false
		 }
	}

	public var data: Data? {
		switch self {
		case .nonHTTPResponse(_, let data): return data
		case .requestFailed(_, _, let data): return data
		case .message: return nil
		case .redirectError(_, _, let data): return data
		case .serverError(_, _, let data): return data
		case .networkError: return nil
		case .unknownError(_, _, let data): return data
		case .decodingError: return nil
		case .offline: return nil
		case .other: return nil
		case .unreachableError: return nil
		}
	}
    
    public var errorDescription: String? {
        switch self {
		  case .nonHTTPResponse(let url, let data): return "Non HTTP Response: \(url.absoluteString(replacement: nil)): \(String(data: data, encoding: .utf8) ?? "--")"
        case .offline: return "The connection appears to be offline"
        case .requestFailed(_, let code, let data): return prettyString("Request failed", nil, code, data)
		  case .message(let msg): return msg
        case .redirectError(_, let code, let data): return prettyString("Request failed", nil, code, data)
        case .serverError(_, let code, let data): return prettyString("Request failed", nil, code, data)
        case .unknownError(_, let code, let data): return prettyString("Request failed", nil, code, data)
		  case .networkError(_, let err): return err.localizedDescription
        case .decodingError(_, let err): return err.localizedDescription
		  case .other(let err): return err?.localizedDescription ?? "unknown error"
		  case .unreachableError: return "We should never get here"
        }
    }
	
	public var failureReason: String? {
		switch self {
		case .nonHTTPResponse(let url, let data): return "Non HTTP Response: \(url.absoluteString()): \(String(data: data, encoding: .utf8) ?? "--")"
		case .offline: return "The connection appears to be offline"
		case .message(let msg): return msg
		case .requestFailed(let url, let code, let data): return prettyString("Request failed", url, code, data)
		case .redirectError(let url, let code, let data): return prettyString("Request failed", url, code, data)
		case .serverError(let url, let code, let data): return prettyString("Request failed", url, code, data)
		case .unknownError(let url, let code, let data): return prettyString("Request failed", url, code, data)
	   case .networkError(let url, let err): return url.absoluteString() + ": " + err.localizedDescription
		case .decodingError(let url, let err): return url.absoluteString() + ": " + err.localizedDescription
		case .other(let err): return err?.localizedDescription ?? "unknown error"
		case .unreachableError: return "Something bad happened"
		}
	}

	func prettyString(_ title: String, _ url: URL?, _ code: Int, _ data: Data?) -> String {
		let prefix = url == nil ? "" : "\(url.absoluteString()): "
        if let data = data, let string = String(data: data, encoding: .utf8), string.isNotEmpty {
            return "\(prefix)\(title) (\(code)): \(string)"
        }
		return "\(prefix)\(title) (\(code))"
    }

    public var isRetriable: Bool {
        switch self {
		  case .other: return false
        case .offline: return false
        case .redirectError: return false
        case .unknownError: return false
		  case .message: return false
        case .decodingError: return false
        case .requestFailed(_, let status, _):
            let timeoutStatus = 408
            let rateLimitStatus = 429
            return status == timeoutStatus || status == rateLimitStatus
            
        case .serverError, .networkError, .nonHTTPResponse:
            return true
		  case .unreachableError: return false
       }
    }
}
