//
//  Image.swift
//  
//
//  Created by Ben Gottlieb on 5/14/20.
//

#if canImport(Combine)
import SwiftUI
import Studio

@available(OSX 10.15, iOS 13.0, *)
public extension Image {
	@inlinable func resizeTo(_ mode: ContentMode = .fit, _ size: CGSize) -> some View {
		return self
			.resizable()
			.aspectRatio(contentMode: mode)
			.frame(size: size)
	}

	init(_ sfsymbol: SFSymbol) {
		self.init(systemName: sfsymbol.rawValue)
	}
}


#endif
