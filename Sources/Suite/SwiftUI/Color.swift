//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 3/5/20.
//

#if canImport(Combine)

import SwiftUI

@available(OSX 10.15, iOS 13.0, *)
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

}



#endif

