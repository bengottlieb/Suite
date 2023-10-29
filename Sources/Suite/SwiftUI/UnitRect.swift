//
//  UnitRect.swift
//
//
//  Created by Ben Gottlieb on 10/29/23.
//

import SwiftUI

public struct UnitSize: Hashable, Sendable, Equatable {
	public var width: CGFloat
	public var height: CGFloat
	
	public init(width: CGFloat, height: CGFloat) {
		self.width = width
		self.height = height
	}
}

public struct UnitRect: Hashable, Sendable, Equatable {
	public var origin: UnitPoint
	public var size: UnitSize
	
	public init(origin: UnitPoint = .zero, size: UnitSize) {
		self.origin = origin
		self.size = size
	}
}
