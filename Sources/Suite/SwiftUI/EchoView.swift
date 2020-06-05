//
//  EchoView.swift
//  
//
//  Created by ben on 6/5/20.
//

#if canImport(Combine)

import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct Echo: View {
	let text: String?
	
	public init(_ text: String?) {
		self.text = text
	}

	public var body: some View {
		if text != nil { print(text!) }
		return Text("Hello")
	}
}

#endif
