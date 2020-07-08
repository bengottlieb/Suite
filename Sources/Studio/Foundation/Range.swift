//
//  Range.swift
//  
//
//  Created by Ben Gottlieb on 7/6/20.
//

import Foundation

public extension Range where Bound: FloatingPoint {
	var delta: Bound { upperBound - lowerBound }
}
