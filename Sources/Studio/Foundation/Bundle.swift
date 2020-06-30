//
//  MobileProvisionFile.swift
//  Suite
//
//  Created by Ben Gottlieb on 9/9/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import Foundation

extension Bundle {
	public var version: String { return self.infoDictionary?["CFBundleShortVersionString"] as? String ?? "" }
	public var buildNumber: String { return self.infoDictionary?["CFBundleVersion"] as? String ?? "" }
	public var name: String { return self.infoDictionary?["CFBundleName"] as? String ?? "" }
	public var copyright: String { return self.infoDictionary?["NSHumanReadableCopyright"] as? String ?? "" }
}

extension NSObject {
	public var bundle: Bundle? { return Bundle(for: type(of: self)) }
	public class var bundle: Bundle? { return Bundle(for: self) }
}

#if os(iOS)
	import UIKit

	extension Bundle {
		public func image(named: String, compatibleWith: UITraitCollection? = nil) -> UIImage? {
			return UIImage(named: named, in: self, compatibleWith: compatibleWith)
		}
	}

#endif

public extension Bundle {
	func directory(named: String, filteredFor: String? = nil) -> Directory? {
		return Directory(bundle: self, name: named, extension: filteredFor)
	}
	
	struct Directory {
		public let urls: [URL]
		init?(bundle: Bundle, name: String, extension ext: String? = nil) {
			guard let urls = bundle.urls(forResourcesWithExtension: ext, subdirectory: name) else {
				self.urls = []
				return nil
			}
			self.urls = urls
		}
		
		public subscript(name: String) -> URL? {
			for url in self.urls {
				if url.deletingPathExtension().lastPathComponent.lowercased() == name.lowercased() { return url }
			}
			return nil
		}
	}
}
