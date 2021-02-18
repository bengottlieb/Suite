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
    public let weight: Font.Weight
    public let design: Font.Design
    public let isSystem: Bool
	
    public init(_ family: String, size: CGFloat) {
		self.family = family
		self.size = size
        self.weight = .regular
        self.design = .default
        isSystem = false
	}
	
    public init(systemSize: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) {
        #if os(iOS)
            family = UIFont.systemFont(ofSize: systemSize).familyName
        #endif
        #if os(OSX)
            family = NSFont.systemFont(ofSize: systemSize).familyName!
        #endif
        size = systemSize
        self.weight = weight
        self.design = design
        isSystem = true
    }
    
    public static func system(size: CGFloat, weight: Font.Weight, design: Font.Design) -> ImprovedFont {
        ImprovedFont(systemSize: size, weight: weight, design: design)
    }
    
    #if os(iOS)
        public var uiFont: UIFont { UIFont(name: family, size: size) ?? .systemFont(ofSize: size) }
    #endif

    
	public var font: Font {
        if isSystem {
            return Font.system(size: size, weight: weight, design: design)
        } else {
            return Font.custom(family, size: size)
        }
    }
	
	public func ofSize(_ size: CGFloat) -> Font { Font.custom(family, size: size) }
	
	public func bumpSize(_ delta: CGFloat) -> Font { Font.custom(family, size: size + delta) }
}
#endif
