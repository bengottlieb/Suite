//
//  RawCollection.swift
//  
//
//  Created by Ben Gottlieb on 1/27/23.
//

import Foundation

public protocol StringInitializable: Hashable {
	init?(rawValue: String)
	var stringValue: String { get }
}

public struct RawCollection<Element: StringInitializable>: RawRepresentable {
	public var elements: Set<Element>

	public init?(rawValue: String) {
		 elements = Set(rawValue.components(separatedBy: ",").compactMap(Element.init))
	}

	public init() {
		elements = []
	}
	
	public var rawValue: String { elements.map { $0.stringValue }.joined(separator: ",") }
	
	public subscript(item: Element) -> Bool {
		get { elements.contains(item) }
		set {
			if newValue {
				elements.remove(item)
			} else {
				elements.insert(item)
			}
		}
	}
}

