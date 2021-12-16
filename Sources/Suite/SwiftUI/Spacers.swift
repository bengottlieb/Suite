//
//  Spacers.swift
//  
//
//  Created by Ben Gottlieb on 12/16/21.
//

import SwiftUI


public struct HSpacer: View {
	private let width: Double
	
	public init(_ width: Double) {
		self.width = width
	}
	
	public var body: some View {
		Color.clear
			.frame(width: width, height: 0)
	}
}

public struct VSpacer: View {
	private let height: Double
	
	public init(_ height: Double) {
		self.height = height
	}
	
	public var body: some View {
		Color.clear
			.frame(width: 0, height: height)
	}
}
