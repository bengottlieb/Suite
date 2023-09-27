//
//  Enums.swift
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

	func next() -> Self {
		let all = Array(Self.allCases)
		
		for i in 0..<all.count {
			if all[i] == self, i < (all.count - 1) {
				return all[i + 1]
			}
		}
		return all[0]
	}
}

public extension Equatable {
	func next(in options: [Self]) -> Self {
		guard let index = options.firstIndex(of: self), index < (options.count - 1) else { return options[0]}
		return options[index + 1]
	}
}
