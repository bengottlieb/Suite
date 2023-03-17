//
//  Color.swift
//  
//
//  Created by Ben Gottlieb on 3/5/20.
//

#if canImport(Combine)

import SwiftUI
import Studio

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension View {
    func backgroundColor(_ color: Color) -> some View {
        self.background(color)
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension Color {
	init?(hex: String?) {
		guard let values = hex?.extractedHexValues else {
			self.init(white: 0, opacity: 0)
			return nil
		}

		self.init(red: values[0], green: values[1], blue: values[2], opacity: values.count > 3 ? values[3] : 1.0)
	}
	
	
    init(red: Int, green: Int, blue: Int, alpha: Double = 1.0) {
		self.init(red: Double(red.capped(0...255)) / 255.0, green: Double(green.capped(0...255)) / 255.0, blue: Double(blue.capped(0...255)) / 255.0, opacity: alpha)
    }

    init(hex: Int, alpha: Double = 1.0) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF, alpha: alpha)
    }

	static var random: Color {
		Color(red: Int.random(in: 0...255), green: Int.random(in: 0...255), blue: Int.random(in: 0...255))
	}

	static var randomGray: Color {
		Color(white: Double.random(in: 0...100.0))
	}
}


#if os(macOS) && !targetEnvironment(macCatalyst)
	import AppKit

	@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
	public extension Color {
		static var systemBackground: Color { Color(NSColor.windowBackgroundColor) }
		static var tertiaryText: Color { Color(NSColor.tertiaryLabelColor) }
	}

	@available(OSX 11, *)
		public extension Color {
			var hex: String? {
				let uic = NSColor(self)
				guard let components = uic.cgColor.components, components.count >= 3 else {
					return nil
				}
				let r = Float(components[0])
				let g = Float(components[1])
				let b = Float(components[2])
				var a = Float(1.0)
				
				if components.count >= 4 {
					a = Float(components[3])
				}
				
				if a != Float(1.0) {
					return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
				} else {
					return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
				}
			}
		}

#elseif canImport(UIKit) && os(iOS)
	import UIKit

	@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
	public extension Color {
		static var systemBackground: Color { Color(UIColor.systemBackground) }
		static var systemLabel: Color { Color(UIColor.label) }
		static var tertiaryText: Color { Color(UIColor.tertiaryLabel) }
	}

	@available(iOS 14.0, tvOS 13, watchOS 6, *)
	public extension Color {
		var hex: String? {
			let uic = UIColor(self)
			guard let components = uic.cgColor.components, components.count >= 3 else {
				return nil
			}
			let r = Float(components[0])
			let g = Float(components[1])
			let b = Float(components[2])
			var a = Float(1.0)
			
			if components.count >= 4 {
				a = Float(components[3])
			}
			
			if a != Float(1.0) {
				return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
			} else {
				return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
			}
		}
	}
#endif


#endif

