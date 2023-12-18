//
//  NavigationTitle.swift
//
//
//  Created by Ben Gottlieb on 12/17/23.
//

import SwiftUI

@available(iOS 14, *)
extension View {
	public func inlineNavigationBar() -> some View {
		#if os(iOS)
			self.navigationBarTitleDisplayMode(.inline)
		#else
			self
		#endif
	}
}
