//
//  Optional.swift
//  
//
//  Created by Ben Gottlieb on 11/28/19.
//

import Foundation

public extension Optional where Wrapped: Comparable {
	static func <(lhs: Wrapped?, rhs: Wrapped?) -> Bool {
		guard let lh = lhs else { return false }
		guard let rh = lhs else { return true }
		return lh < rh
	}
}

public extension Optional {
	enum UnwrappedOptionalError: Error { case failedToUnwrap }
	func unwrap() throws -> Wrapped {
		switch self {
		case .none: throw UnwrappedOptionalError.failedToUnwrap
		case .some(let wrapped): return wrapped
		}
	}
}

public extension Optional where Wrapped: Collection {
    var isEmpty: Bool {
        switch self {
        case .none: return true
        case .some(let wrapped): return wrapped.isEmpty
        }
    }

    var isNotEmpty: Bool {
        switch self {
        case .none: return false
        case .some(let wrapped): return wrapped.isNotEmpty
        }
    }
}
