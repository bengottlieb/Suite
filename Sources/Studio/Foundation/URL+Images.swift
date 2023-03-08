//
//  URL+Images.swift
//  
//
//  Created by ben on 5/30/20.
//

#if !os(watchOS)
import Foundation
import CoreGraphics

extension URL {
	private func resizedImage(maxDimension: CGFloat) -> CGImage? {
		let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
		let downsampleOptions: CFDictionary =  [kCGImageSourceCreateThumbnailFromImageAlways: true,
								  kCGImageSourceShouldCacheImmediately: true,
								  kCGImageSourceCreateThumbnailWithTransform: true,
																		 kCGImageSourceThumbnailMaxPixelSize: maxDimension] as [CFString : Any] as CFDictionary

		guard
			let imageSource = CGImageSourceCreateWithURL(self as CFURL, imageSourceOptions),
			let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)
		else {
			return nil
		}

		return downsampledImage
	}
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
extension URL {
	/// Resize an image on-disk without first loading it in
	func resizedContainedImage(maxDimension: CGFloat) -> NSImage? {
		guard let cgImage = self.resizedImage(maxDimension: maxDimension) else { return nil }
		return NSImage(cgImage: cgImage, size: NSSize(width: maxDimension, height: maxDimension))
	}
}
#endif

#if canImport(UIKit)
import UIKit
extension URL {
	/// Resize an image on-disk without first loading it in
	func resizedContainedImage(maxDimension: CGFloat) -> UIImage? {
		guard let cgImage = self.resizedImage(maxDimension: maxDimension) else { return nil }
		return UIImage(cgImage: cgImage)
	}
}
#endif
#endif
