//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 4/16/20.
//

import Foundation

public extension CaseIterable {
	static func random() -> Self { return Self.allCases.randomElement()! }
}

public extension CaseIterable where Self: Equatable {
    var isLastCase: Bool {
        self == Array(Self.allCases).last
    }
}
