//
//  Operators.swift
//  
//
//  Created by Ben Gottlieb on 11/30/19.
//

import Foundation

infix operator ?= : AssignmentPrecedence
infix operator ∆= : AssignmentPrecedence
infix operator ≈≈ : ComparisonPrecedence
infix operator !≈ : ComparisonPrecedence

public func ?=<T>( left: inout T, right: T?) {
	guard let value = right else { return }
	left = value
}

public func ?=<T>( left: inout T?, right: T?) {
	guard let value = right else { return }
	left = value
}

@discardableResult public func ∆=<T: Equatable>( left: inout T, right: T) -> T {
	if left != right { left = right }
	return left
}

@discardableResult public func ∆=<T: Equatable>( left: inout T?, right: T) -> T? {
	if left != right { left = right }
	return left
}
