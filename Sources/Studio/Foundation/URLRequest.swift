//
//  URLRequest.swift
//  
//
//  Created by ben on 12/15/20.
//

import Foundation

public extension URLRequest {
	enum RequestMethod: String { case get, put, post, delete, head, connect, patch, options, trace }
	
	var requestMethod: RequestMethod {
		get { RequestMethod(rawValue: httpMethod?.lowercased() ?? "") ?? .get }
		set { httpMethod = newValue.rawValue.uppercased() }
	}
	
	var curl: String {
		guard let url = url else { return "" }
		var baseCommand = "curl \"\(url.absoluteString)\""
		
		if httpMethod == "HEAD" {
			baseCommand += " --head"
		}
		
		var command = [baseCommand]
		
		if requestMethod != .get, requestMethod != .head {
			command.append("-X \(requestMethod.rawValue)")
		}
		
		if let headers = allHTTPHeaderFields {
			for (key, value) in headers where key != "Cookie" {
				command.append("-H '\(key): \(value)'")
			}
		}
		
		if let data = httpBody, let body = String(data: data, encoding: .utf8) {
			command.append("-d '\(body)'")
		}
		
		return command.joined(separator: " \\\n\t")
	}
	
}
