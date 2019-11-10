//
//  Data.swift
//  
//
//  Created by ben on 11/10/19.
//

import Foundation

public extension Data {
	func debug_save(to name: String) {
		let url = FileManager.documentsDirectory.appendingPathComponent(name + ".dat")
		do {
			try self.write(to: url)
		} catch {
			print("Error when writing data to \(url): \(error)")
		}
	}
}
