//
//  ObservableStub.swift
//  
//
//  Created by Ben Gottlieb on 1/3/22.
//

import SwiftUI

#if canImport(Combine)

import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public class ObservableStub: ObservableObject {
	public init() {
		
	}
	
	public func nudge() {
		Task { await MainActor.run { self.objectWillChange.send() }}
	}
}
#endif
