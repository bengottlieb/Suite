//
//  GeometryReader.swift
//  
//
//  Created by Ben Gottlieb on 3/21/21.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public extension GeometryProxy {
    var width: CGFloat { size.width }
    var height: CGFloat { size.height }
}


#endif
