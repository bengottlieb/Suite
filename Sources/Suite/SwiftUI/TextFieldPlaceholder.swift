//
//  TextFieldPlaceholder.swift
//  
//
//  Created by Ben Gottlieb on 9/24/21.
//

import SwiftUI

#if canImport(Combine)
import SwiftUI

@available(macOS 10.15, iOS 13.0, watchOS 7.0, *)
extension View {
	public func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
		ZStack(alignment: alignment) {
			placeholder().opacity(shouldShow ? 1 : 0)
			self
		}
	}
}
#endif
