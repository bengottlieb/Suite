//
//  View+Printing.swift
//
//
//  Created by Ben Gottlieb on 11/19/23.
//

import SwiftUI

let letterPageSize = CGSize(width: 612, height: 792)

#if os(iOS)
public extension View {
	@available(iOS 16.0, *)
	@MainActor func imageForPrinting() -> UIImage? {
		ImageRenderer(content: self.frame(width: letterPageSize.width, height: letterPageSize.height)).uiImage
	}
}
#endif

public extension View {
	@available(iOS 16.0, macOS 13.0, *)
    @MainActor func urlForPrintedPage(named: String, ignoreCache: Bool = false) -> URL? {
		let url = URL.cache(named: named)
		if !ignoreCache, FileManager.default.fileExists(at: url) { return url }
		guard let image = imageForPrinting() else { return nil }
		
        try? FileManager.default.removeItem(at: url)
        guard let data = image.pngData() else { return nil }
		
		do {
			try data.write(to: url)
			return url
		} catch {
			return nil
		}
	}
}

#if os(macOS)
public extension View {
	@available(macOS 13.0, *)
	@MainActor func imageForPrinting() -> NSImage? {
		ImageRenderer(content: self.frame(width: letterPageSize.width, height: letterPageSize.height)).nsImage
	}
}
#endif
