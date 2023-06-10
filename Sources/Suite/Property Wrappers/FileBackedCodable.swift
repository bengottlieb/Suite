//
//  FileBackedCodable.swift
//  Strongest
//
//  Created by Ben Gottlieb on 7/9/21.
//  Copyright © 2021 Strongest AI, Inc. All rights reserved.
//

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
@propertyWrapper public struct FileBackedCodable<Item: Codable>: DynamicProperty {
	public var wrappedValue: Item {
		get { storage.value }
		nonmutating set { storage.value = newValue }
	}
	
	@ObservedObject private var storage: Storage<Item>
	public var url: URL { storage.url }
	
	public func save() {
		storage.startSave()
	}
	
	public init(url: URL, initialValue: Item) {
		storage = Storage(url: url, initial: initialValue)
	}
	
	internal class Storage<Item: Codable>: ObservableObject {
		init(url: URL, initial: Item) {
			self.url = url
			self.value = initial
			do {
				let data = try Data(contentsOf: url)
				self.value = try Item.loadJSON(data: data)
			} catch {
			}
		}
		
		let url: URL
		var value: Item {
			willSet { objectWillChange.send() }
			didSet { startSave() }
		}
		
		func startSave() {
			do {
				let data = try value.asJSONData()
				try data.write(to: url)
			} catch {
				logg(error: error, "Error writing to \(url.path)")
			}
		}
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
@propertyWrapper public struct FileBackedCodableOptional<Item: Codable>: DynamicProperty {
	public var wrappedValue: Item? {
		get { storage.value }
		nonmutating set { storage.value = newValue }
	}
	
	@ObservedObject private var storage: Storage
	
	public func save() {
		storage.startSave()
	}
	public var url: URL { storage.url }

	public init(url: URL, initialValue: Item?) {
		storage = Storage(url: url, initial: initialValue)
	}
	
	internal class Storage: ObservableObject {
		init(url: URL, initial: Item? = nil) {
			self.url = url
			self.value = initial
			do {
				let data = try Data(contentsOf: url)
				self.value = try Item.loadJSON(data: data)
			} catch {
			}
		}
		
		let url: URL
		var value: Item? {
			willSet { objectWillChange.send() }
			didSet { startSave() }
		}
		
		func startSave() {
			do {
				if let item = value {
					let data = try item.asJSONData()
					try data.write(to: url)
				} else {
					try? FileManager.default.removeItem(at: url)
				}
			} catch {
				logg(error: error, "Error writing to \(url.path)")
			}
		}
	}
}
#endif
