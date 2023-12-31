//
//  OnDemandFetcher.swift
//
//
//  Created by Ben Gottlieb on 12/23/23.
//

import Foundation

#if os(iOS)
public struct OnDemandFetcher {
	struct StoredDictionary: Codable {
		let version: Int
		let dictionary: [String: String]
	}
	
	public static func fetchDictionary(key: String, version: Int = 1) async throws -> [String: String] {
		let keychainKey = "ondemand_\(key)"
		if let keychainData = Keychain.instance.data(forKey: keychainKey), let cached = try? JSONDecoder().decode(StoredDictionary.self, from: keychainData), cached.version == version {
			return cached.dictionary
		}
		
		let request = NSBundleResourceRequest(tags: [key], bundle: .main)
		try await request.beginAccessingResources()
		
		let url = Bundle.main.url(forResource: "Keys", withExtension: "json")!
		let data = try Data(contentsOf: url)
		let json = try JSONDecoder().decode([String: String].self, from: data)
		let cache = StoredDictionary(version: version, dictionary: json)
		
		if let cacheData = try? JSONEncoder().encode(cache) {
			Keychain.instance.set(cacheData, forKey: keychainKey)
		}
		
		request.endAccessingResources()
		return json
	}
}
#endif
