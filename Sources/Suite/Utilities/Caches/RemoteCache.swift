//
//  RemoteCache.swift
//  
//
//  Created by ben on 1/7/21.
//

import Foundation

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public protocol RemoteCacheRequestBuilder {
	func request(from url: URL) -> AnyPublisher<URLRequest, Error>
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public class RemoteCache<Element: Cachable>: Cache<Element> {
	let session: URLSession
	let requestBuilder: RemoteCacheRequestBuilder?
    var inflightRequests: [URL: AnyPublisher<Element, Error>] = [:]
	
	public init(session urlSession: URLSession = .shared, requestBuilder builder: RemoteCacheRequestBuilder? = nil) {
		session = urlSession
		requestBuilder = builder
		super.init(backingCache: nil)
	}
	
	public override func cachedValue(for url: URL, newerThan date: Date? = nil) -> Element? { nil }
	
	public override func fetch(for url: URL, caching: URLRequest.CachePolicy = .default) -> AnyPublisher<Element, Error> {
        if caching != .reloadIgnoringLocalCacheData, let inflight = inflightRequests[url] { return inflight }
		if caching == .returnCacheDataDontLoad {
			return Fail(outputType: Element.self, failure: CacheError.noLocalItemFound(url)).eraseToAnyPublisher()
		}
		
		if let builder = requestBuilder {
			return builder.request(from: url)
				.flatMap { request in
					self.publisher(for: request)
				}
				.eraseToAnyPublisher()
		}
		
		return publisher(for: URLRequest(url: url))
	}
	
	func publisher(for request: URLRequest) -> AnyPublisher<Element, Error> {
        guard let url = request.url else { return Fail(outputType: Element.self, failure: CacheError.noURL).eraseToAnyPublisher() }
        let pub: AnyPublisher<Element, Error> = session.dataTaskPublisher(for: request)
            .assumeHTTP()
            .responseData()
			.mapError { error -> Error in
                self.inflightRequests.removeValue(forKey: url)
                return error.isOffline ? error : CacheError.failedToDownloadServerError(request.url!, error)
			}
			.tryMap { data in
                self.inflightRequests.removeValue(forKey: url)
				if let result = Element.create(with: data) as? Element { return result }
				throw CacheError.failedToDownload(request.url!, data)
			}
			.eraseToAnyPublisher()
        
        inflightRequests[url] = pub
        return pub
	}
}



#endif
