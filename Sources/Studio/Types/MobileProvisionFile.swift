//
//  MobileProvisionFile.swift
//  Suite
//
//  Created by Ben Gottlieb on 9/9/19.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation

public class MobileProvisionFile {
	public convenience init?(url: URL?) { self.init(data: url == nil ? nil : try? Data(contentsOf: url!)) }
	
	public var properties: NSDictionary!
	
	public static var `default`: MobileProvisionFile? = MobileProvisionFile(url: Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"))
	public init?(data: Data?) {
		guard let data = data else { return nil }
		
		let xmlPrefix = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
		let xmlSuffix = "</plist>"
		guard let file = String(data: data, encoding: .ascii) else { return nil }
		if let chunk = file.extractSubstring(start: xmlPrefix, end: xmlSuffix) {
			let full = xmlPrefix + chunk + xmlSuffix
			self.properties = full.propertyList() as? NSDictionary
		}
		if self.properties == nil { return nil }
	}
	
	public var cloudContainers: [String] {
		guard let entitlements = dictionary(for: "Entitlements") else { return [] }
		
		return entitlements["com.apple.developer.icloud-container-development-container-identifiers"] as? [String] ?? []
	}
	
	public func dictionary(for key: String) -> [String: Any]? {
		self.properties?[key] as? [String: Any]
	}
	
}

extension Scanner {
    func scanStringUpTo(string: String) -> String? {
		if #available(iOS 13.0, iOSApplicationExtension 13.0, watchOS 6.0, OSX 10.15, OSXApplicationExtension 10.15, *) {
            return self.scanString(string)
        } else {
            var result: NSString?
            self.scanUpTo(string, into: &result)
            return result as String?
        }
    }
}
