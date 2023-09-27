//
//  CGContext.swift
//  
//
//  Created by Ben Gottlieb on 5/18/23.
//

import CoreGraphics

#if canImport(UIKit)
import UIKit

public extension UIImage {
	func buildContext(_ alphaStyle: CGImageAlphaInfo = .premultipliedLast) -> CGContext? {
		let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: Int(self.size.width * 4), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: alphaStyle.rawValue)
		
		if let image = self.cgImage { ctx?.draw(image, in: self.size.rect) }
		return ctx
	}
	func writeToURL(_ url: URL) { try? pngData()?.write(to: url, options: [.atomic]) }
	func snapshotToDocuments(_ filename: String? = nil) {
		let date = Date()
		let name = filename ?? "\(date)-\(date.timeIntervalSince1970)"
		let url = URL.document(named: "\(name).png")
		self.writeToURL(url)
	}

}

public extension CGContext {
	var CGImage: CGImage? { return self.makeImage() }
	var image: UIImage? { return self.CGImage?.image }
	var pngData: Data? { return self.CGImage?.pngData }
	func writeToURL(_ url: URL) { self.CGImage?.writeToURL(url) }
	func snapshotToDocuments() { self.CGImage?.snapshotToDocuments() }
	var bytes: UnsafeMutablePointer<UInt8>? {
		  if let ptr = self.data?.bindMemory(to: UInt8.self, capacity: self.height * self.bytesPerRow * 4) {
				return ptr
		  }
		  return nil
	}
	var uint32s: UnsafeMutablePointer<UInt32>? {
		  if let ptr = self.data?.bindMemory(to: UInt32.self, capacity: self.height * self.bytesPerRow) {
				return ptr
		  }
		  return nil
	}
}

public extension CGImage {
	var image: UIImage? { return UIImage(cgImage: self) }
	var pngData: Data? { return image?.pngData() }
	func jpegData(_ quality: CGFloat = 0.9) -> Data? { return image?.jpegData(compressionQuality: quality) }
	var jpegData: Data? { return jpegData() }
	func writeToURL(_ url: URL) { image?.writeToURL(url) }
	func snapshotToDocuments() { image?.snapshotToDocuments() }
	
}

public extension CGContext {
	 func isEmpty(consideringBackground color: UIColor? = nil) -> Bool {
		  let width = self.width
		  let height = self.height
		  let pixelsPerRow = self.bytesPerRow / 4
		  guard let data = self.bytes else { return true }
		  let uint32s = data.withMemoryRebound(to: UInt32.self, capacity: height * pixelsPerRow) { data in return data }
		  let alphaInfo = self.alphaInfo
		  let backgroundInt = color?.hex ?? 0
		  
		  for x in 0..<width {
				for y in 0..<height {
					 if self.alphaOfPixelAt(x, y: y, pixelsPerRow: pixelsPerRow, style: alphaInfo, inData: data) == 0 { continue }
					 if backgroundInt != 0 && uint32s[x + y * pixelsPerRow] == backgroundInt { continue }
					 return false
				}
		  }
		  return true
	 }
	 
	 func contentFrame(consideringBackground background: UIColor? = nil) -> CGRect? {
		let width = self.width
		let height = self.height
		let pixelsPerRow = self.bytesPerRow / 4
		var content = CGRect(x: -1, y: -1, width: 0, height: 0)
		  guard let data = self.bytes else { return nil }
		  let uint32s = data.withMemoryRebound(to: UInt32.self, capacity: height * pixelsPerRow) { data in return data }
		let alphaInfo = self.alphaInfo
		  let backgroundInt = background?.hex ?? 0
		  
		for x in 0..<width {
			for y in 0..<height {
					 if self.alphaOfPixelAt(x, y: y, pixelsPerRow: pixelsPerRow, style: alphaInfo, inData: data) == 0 { continue }
					 if backgroundInt != 0 && uint32s[x + y * pixelsPerRow] == backgroundInt { continue }
					 
					 if content.origin.x == -1 {
						  content.origin.x = CGFloat(x)
					 } else if CGFloat(x) > content.maxX {
						  content.size.width = CGFloat(x) - content.origin.x
					 } else if CGFloat(x) < content.origin.x {
						  let delta = content.origin.x - CGFloat(x)
						  content.size.width += delta
						  content.origin.x -= delta
					 }
					 
					 if content.origin.y == -1 {
						  content.origin.y = CGFloat(y)
					 } else if CGFloat(y) > content.maxY {
						  content.size.height = CGFloat(y) - content.origin.y
					 } else if CGFloat(y) < content.origin.y {
						  let delta = content.origin.y - CGFloat(y)
						  content.size.height += delta
						  content.origin.y -= delta
					 }
				}
		}
		
		if content.origin.x == -1 || content.origin.y == -1 { return nil }
		return content
	}
	
	func alphaOfPixelAt(_ x: Int, y: Int, pixelsPerRow: Int, style alphaInfo: CGImageAlphaInfo, inData data: UnsafePointer<UInt8>) -> UInt8 {
		let offset = y * pixelsPerRow * 4 + x * 4
		
		if alphaInfo == .premultipliedFirst {
			let byte = data[offset]
			return 255 - byte
		} else {
			let byte = data[offset + 3]
			return byte
		}
	}
	
	func colorOfPixelAtPoint(_ location: CGPoint) -> UIColor? {
		let width = self.width
		let height = self.height
		guard location.x >= 0 && location.y >= 0 && Int(location.x) < width && Int(location.y) < height else { return nil }
		
		
		let ctx = self
		
		  if let actualData = ctx.uint32s {
				let bytesPerRow = ctx.bytesPerRow
				let offset = Int(location.x) + Int(location.y) * (bytesPerRow / 4)
				let pixel = actualData[offset]
				
				return UIColor(unpacked: pixel, withAlphaStyle: ctx.alphaInfo)
		  }

		  return nil
	}
}
#endif
