//
//  Data.swift
//  
//
//  Created by ben on 11/10/19.
//

import Foundation

public extension Data {
	@discardableResult
	func debug_save(to name: String) -> URL! {
		let url = FileManager.documentsDirectory.appendingPathComponent(name + ".dat")
		do {
			try self.write(to: url)
			return url
		} catch {
			print("Error when writing data to \(url): \(error)")
			return nil
		}
	}
}
