//
//  AsyncWebView.swift
//  
//
//  Created by Ben Gottlieb on 10/10/22.
//

#if canImport(WebKit)
import WebKit

public class AsyncWebView: NSObject, WKNavigationDelegate {
	var continuation: CheckedContinuation<Void, Error>?
	public let webView = WKWebView(frame: .init(x: 0, y: 0, width: 100, height: 100))
	
	public override init() {
		super.init()
		webView.navigationDelegate = self
	}
	
	public func load(_ url: URL) async throws {
		try await load(URLRequest(url: url))
	}
	
	public func load(_ request: URLRequest) async throws {
		let _: Void = try await withCheckedThrowingContinuation { continuation in
			self.continuation = continuation
			DispatchQueue.main.async { _ = self.webView.load(request) }
		}
	}
	
	public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		continuation?.resume(throwing: error)
		continuation = nil
	}
	
	public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		continuation?.resume()
		continuation = nil
	}
}
#endif
