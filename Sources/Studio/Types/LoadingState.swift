//
//  LoadingState.swift
//  
//
//  Created by ben on 11/26/20.
//

import Foundation

public enum LoadingState<Value>: Equatable { case idle, loading, failed(Error), loaded(Value)
	public static func ==(lhs: LoadingState, rhs: LoadingState) -> Bool {
		switch (lhs, rhs) {
		case (.idle, .idle): return true
		case (.loading, .loading): return true
		case (.failed, .failed): return true
		default: return false
		}
	}
	
	public var isLoaded: Bool {
		if case .loaded = self { return true }
		return false
	}
	
	public var error: Error? {
		if case let .failed(error) = self { return error }
		return nil
	}
	
}

