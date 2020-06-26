//
//  Data.swift
//  
//
//  Created by ben on 11/10/19.
//

import Foundation

public extension Data {
	var rawJSON: Any? {
		try? JSONSerialization.jsonObject(with: self, options: [])
	}

	@discardableResult
	func debug_save(to name: String) -> URL! {
		let url = FileManager.documentsDirectory.appendingPathComponent(name + ".dat")
		do {
			try self.write(to: url)
			return url
		} catch {
			elog(error, "Writing data to \(url)")
			return nil
		}
	}
}
