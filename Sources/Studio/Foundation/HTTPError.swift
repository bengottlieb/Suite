//
//  HTTPError.swift
//  
//
//  Created by Ben Gottlieb on 3/1/21.
//

import Foundation

extension Optional where Wrapped == URL {
	public var absoluteString: String { self?.absoluteString ?? "Missing URL" }
}

public enum HTTPError: Error, LocalizedError {
    case nonHTTPResponse(URL?, Data)
    case offline
    case requestFailed(URL?, Int, Data)
    case redirectError(URL?, Int, Data)
    case serverError(URL?, Int, Data)
    case unknownError(URL?, Int, Data?)
    case networkError(URL?, Error)
    case decodingError(URL?, DecodingError)

    var isOffline: Bool {
        switch self {
        case .offline: return true
        default: return false
        }
    }
    
    public var errorDescription: String? {
        switch self {
		  case .nonHTTPResponse(let url, let data): return "Non HTTP Response: \(url.absoluteString): \(String(data: data, encoding: .utf8) ?? "--")"
        case .offline: return "The connection appears to be offline"
        case .requestFailed(let url, let code, let data): return prettyString("Request failed", url, code, data)
        case .redirectError(let url, let code, let data): return prettyString("Request failed", url, code, data)
        case .serverError(let url, let code, let data): return prettyString("Request failed", url, code, data)
        case .unknownError(let url, let code, let data): return prettyString("Request failed", url, code, data)
		case .networkError(let url, let err): return url.absoluteString + ": " + err.localizedDescription
        case .decodingError(let url, let err): return url.absoluteString + ": " + err.localizedDescription
        }
    }
	func prettyString(_ title: String, _ url: URL?, _ code: Int, _ data: Data?) -> String {
		if let data = data, let string = String(data: data, encoding: .utf8) { return "\(url.absoluteString): \(title) (\(code)): \(string)"}
		return "\(url.absoluteString): \(title) (\(code))"
    }

    public var isRetriable: Bool {
        switch self {
        case .offline: return false
        case .redirectError: return false
        case .unknownError: return false
        case .decodingError: return false
        case .requestFailed(_, let status, _):
            let timeoutStatus = 408
            let rateLimitStatus = 429
            return status == timeoutStatus || status == rateLimitStatus
            
        case .serverError, .networkError, .nonHTTPResponse:
            return true
        }
    }
}
