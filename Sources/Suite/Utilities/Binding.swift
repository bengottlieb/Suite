//
//  Binding.swift
//  InternalUI
//
//  Created by Ben Gottlieb on 2/19/20.
//  Copyright © 2020 DataBright. All rights reserved.
//

import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension Binding {
	static func empty<Value>(value: Value) -> Binding<Value> {
		return Binding<Value>(get: { return value }) { _ in }
	}

	static func empty<Value>(value: Value? = nil) -> Binding<Value?> {
		return Binding<Value?>(get: { return value }) { _ in }
	}
}
