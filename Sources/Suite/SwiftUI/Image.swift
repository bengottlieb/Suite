//
//  Image.swift
//  
//
//  Created by Ben Gottlieb on 5/14/20.
//

#if canImport(Combine)
import SwiftUI

@available(OSX 10.15, iOS 13.0, *)
public extension Image {
	@inlinable func resizeTo(_ mode: ContentMode = .fit, _ size: CGSize) -> some View {
		return self
			.resizable()
			.aspectRatio(contentMode: mode)
			.frame(size: size)
	}
}


#endif
