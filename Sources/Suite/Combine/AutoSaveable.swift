//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 2/17/22.
//

import Foundation

public protocol AutoSaveable: Codable, ObservableObject {
	static var saveURL: URL { get }
	init()
}

extension AutoSaveable {
	public static func loadSaved() -> Self {
		do {
			if let data = try? Data(contentsOf: saveURL) {
				let decoded = try JSONDecoder().decode(Self.self, from: data)
				return decoded.setupForAutoSave()
			}
		} catch {
			print("Failed to decode \(String(describing: self)): \(error)")
		}
		return Self.init().setupForAutoSave()
	}
	
	func setupForAutoSave() -> Self {
		self
			.objectWillChange
			.sink { [weak self] _ in
				self?.autoSave()
			}
			.sequester(String(describing: self))
		
		return self
	}
	
	public func autoSave() {
		do {
			let data = try JSONEncoder().encode(self)
			try data.write(to: Self.saveURL)
		} catch {
			print("Failed to save \(String(describing: self)): \(error)")
		}
	}
}
