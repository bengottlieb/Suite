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

public protocol AsyncRemoteCacheRequestBuilder {
	func request(from url: URL) async throws -> URLRequest
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

	public override func fetch(for url: URL, caching: URLRequest.CachePolicy = .default) async throws -> Element {
		if caching == .returnCacheDataDontLoad {
			throw CacheError.noLocalItemFound(url)
		}
		
		var request = URLRequest(url: url)
		if let builder = requestBuilder as? AsyncRemoteCacheRequestBuilder {
			request = try await builder.request(from: url)
		}
		
		let result = try await session.data(for: request)
		if let downloaded = Element.create(with: result.0) as? Element {
			return downloaded
		}
		throw CacheError.failedToDownload(url, result.0)
	}

	func publisher(for request: URLRequest) -> AnyPublisher<Element, Error> {
        guard let url = request.url else { return Fail(outputType: Element.self, failure: CacheError.noURL).eraseToAnyPublisher() }
        let pub: AnyPublisher<Element, Error> = session.dataTaskPublisher(for: request)
            .assumeHTTP()
			.mapError { error -> Error in
                self.inflightRequests.removeValue(forKey: url)
                return CacheError.failedToDownloadServerError(request.url!, error)
			}
			.tryMap { data in
                self.inflightRequests.removeValue(forKey: url)
                if let result = Element.create(with: data.data) as? Element { return result }
                throw CacheError.failedToDownload(request.url!, data.data)
			}
			.eraseToAnyPublisher()
        
        inflightRequests[url] = pub
        return pub
	}
}

@available(iOS 13.0, watchOS 6.0, OSX 10.15, *)
fileprivate extension Publisher where Output == (data: Data, response: URLResponse) {
   func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
      tryMap { data, response in
          guard let http = response as? HTTPURLResponse else { throw CacheError.unknownResponse(response.url) }
         return (data, http)
      }
      .eraseToAnyPublisher()
   }
}

#endif
