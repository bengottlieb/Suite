//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 6/6/20.
//

import Foundation
#if canImport(Combine)

import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension Array where Element: Identifiable {
	subscript(id id: Element.ID) -> Element? {
		get {
			guard let index = self.firstIndex(where: { $0.id == id }) else { return nil }
			return self[index]
		}
		
		set {
			if let index = self.firstIndex(where: { $0.id == id }) {
				if let element = newValue {
					self[index] = element
				} else {
					self.remove(at: index)
				}
			} else if let element = newValue {
				self.append(element)
			}
		}
	}
}

extension String: Identifiable {
	public var id: Self { self }
}

extension Int: Identifiable {
	public var id: Self { self }
}

extension Double: Identifiable {
	public var id: Self { self }
}

extension Float: Identifiable {
	public var id: Self { self }
}
#endif
