//
//  ActionView.swift
//  
//
//  Created by Ben Gottlieb on 10/9/21.
//

import Foundation

public struct ActionView: View {
	public init(deferred: Bool = false, _ action: @escaping () -> Void) {
		if deferred {
			DispatchQueue.main.async { action() }
		} else {
			action()
		}
	}
	public var body: some View { EmptyView() }
}

