//
//  Environment.swift
//  
//
//  Created by Ben Gottlieb on 3/19/23.
//

import SwiftUI

public struct IsEditingEnvironmentKey: EnvironmentKey {
	public static var defaultValue = false
}

public extension EnvironmentValues {
	var isEditing: Bool {
		get { self[IsEditingEnvironmentKey.self] }
		set { self[IsEditingEnvironmentKey.self] = newValue }
	}
}


