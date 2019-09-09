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
		
		guard let file = String(data: data, encoding: .ascii) else { return nil }
		let scanner = Scanner(string: file)
		if scanner.scanStringUpTo(string: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>") != nil, let contents = scanner.scanStringUpTo(string: "</plist>") {
			let raw = contents.appending("</plist>")
			self.properties = raw.propertyList() as? NSDictionary
		}
		
		if self.properties == nil { return nil }
	}
}

extension Scanner {
    func scanStringUpTo(string: String) -> String? {
        if #available(iOS 13.0, iOSApplicationExtension 13.0, OSX 10.15, OSXApplicationExtension 10.15, *) {
            return self.scanString(string)
        } else {
            var result: NSString?
            self.scanUpTo(string, into: &result)
            return result as String?
        }
    }
}
