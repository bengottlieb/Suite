//
//  ManagedObjectStore+Metadata.swift
//  Suite
//
//  Created by Ben Gottlieb on 9/10/19.
//  Copyright (c) 2019 Stand Alone, Inc. All rights reserved.
//

import Foundation
import CoreData

extension NSPersistentStoreCoordinator {
	public func clearMetadata() {
		guard let store = self.persistentStores.first else { return }
		if store.url != nil {
			self.setMetadata([:], for: store)
		}
		
	}

	public subscript(key: String) -> Any? {
		get {
			guard let store = self.persistentStores.first else { return nil }
			return self.metadata(for: store)[key]
		}
		set {
			guard let store = self.persistentStores.first else { return }
			var data = self.metadata(for: store)
			data[key] = newValue
			if store.url != nil {
				self.setMetadata(data, for: store)
			}
		}
	}
	
}
