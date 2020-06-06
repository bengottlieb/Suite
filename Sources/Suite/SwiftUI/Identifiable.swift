//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 6/6/20.
//

import Foundation
#if canImport(Combine)

import SwiftUI

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
