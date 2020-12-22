//
//  Deferred.swift
//  
//
//  Created by Ben Gottlieb on 12/21/20.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public struct Deferred<Content: View>: View {
	var builder: () -> Content
	
	public init(_ content: @escaping @autoclosure () -> Content) {
		builder = content
	}
	
	public var body: some View {
		builder()
	}
}

#endif
