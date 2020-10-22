//
//  ImprovedFont.swift
//  
//
//  Created by Ben Gottlieb on 3/31/20.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public struct ImprovedFont {
	public let family: String
	public let size: CGFloat
	
	public init(_ family: String, size: CGFloat) {
		self.family = family
		self.size = size
	}
	
	public var font: Font { Font.custom(family, size: size) }
	
	public func ofSize(_ size: CGFloat) -> Font { Font.custom(family, size: size) }
	
	public func bumpSize(_ delta: CGFloat) -> Font { Font.custom(family, size: size + delta) }
}
#endif
