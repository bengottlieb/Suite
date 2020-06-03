//
//  ActivityIndicatorView.swift
//  
//
//  Created by ben on 5/1/20.
//

#if canImport(Combine)

import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public struct ActivityIndicatorView: View {
	private var color: Color
	private var spokeCount = 12
	private var period: TimeInterval = 1.2
	@State private var gradientRotation = Angle.zero
	
	public init(_ color: Color = .gray) {
		self.color = color
	}
	
	public func small() -> some View {
		self.frame(width: 20, height: 20)
	}
	
	public func large() -> some View {
		self.frame(width: 50, height: 50)
	}
	
	public var body: some View {
		AngularGradient(gradient: .init(colors: [.clear, self.color]), center: .center)
			.rotationEffect(self.gradientRotation)
			.animation(Animation.linear(duration: period).repeatForever(autoreverses: false))
			.mask(self.spokes)
			.onAppear { self.gradientRotation = .radians(2 * .pi) }
	}
	
	var spokes: some View {
		GeometryReader { geo in
			ForEach(0..<self.spokeCount) { index in
				RoundedRectangle(cornerRadius: 2)
					.frame(width: geo.size.width / 20, height: geo.size.height / 5)
					.position(x: geo.size.width / 2, y: geo.size.height / 5)
					.rotationEffect(.radians(2 * .pi * Double(index) / Double(self.spokeCount)))
			}
		}
	}
}

#endif
