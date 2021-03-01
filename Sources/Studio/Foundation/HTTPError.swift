//
//  HTTPError.swift
//  
//
//  Created by Ben Gottlieb on 3/1/21.
//

import Foundation

public enum HTTPError: Error, LocalizedError {
    case nonHTTPResponse(Data)
    case offline
    case requestFailed(Int, Data)
    case redirectError(Int, Data)
    case serverError(Int, Data)
    case unknownError(Int, Data?)
    case networkError(Error)
    case decodingError(DecodingError)

    var isOffline: Bool {
        switch self {
        case .offline: return true
        default: return false
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .nonHTTPResponse(let data): return "Non HTTP Response: \(String(data: data, encoding: .utf8) ?? "--")"
        case .offline: return "The connection appears to be offline"
        case .requestFailed(let code, let data): return prettyString("Request failed", code, data)
        case .redirectError(let code, let data): return prettyString("Request failed", code, data)
        case .serverError(let code, let data): return prettyString("Request failed", code, data)
        case .unknownError(let code, let data): return prettyString("Request failed", code, data)
        case .networkError(let err): return err.localizedDescription
        case .decodingError(let err): return err.localizedDescription
        }
    }
    func prettyString(_ title: String, _ code: Int, _ data: Data?) -> String {
        if let data = data, let string = String(data: data, encoding: .utf8) { return "\(title) (\(code)): \(string)"}
        return "\(title) (\(code))"
    }

    public var isRetriable: Bool {
        switch self {
        case .offline: return false
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
