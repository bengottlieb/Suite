//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 3/5/20.
//

#if canImport(SwiftUI)

import SwiftUI

@available(OSX 10.15, *)
extension Color {
	init?(hexString: String?) {
		guard let values = hexString?.extractedHexValues else {
			self.init(white: 0, opacity: 0)
			return nil
		}

		self.init(red: values[0], green: values[1], blue: values[2], opacity: values.count > 3 ? values[3] : 1.0)
	}
}



#endif

