//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 12/7/19.
//

#if canImport(UIKIt)
import UIKit

public enum ImageFormat: String { case PNG = "png", JPEG = "jpeg"
	public var mimeType: String {
		switch self {
		case .PNG: return "image/png"
		case .JPEG: return "image/jpeg"
		}
	}
}



public extension UIImage {
	enum ImageStoreError: Error { case nonLocalURL, unableToConverToData }
	func store(in url: URL) throws {
		if !url.isFileURL { throw ImageStoreError.nonLocalURL }
		guard let data = self.pngData() else { throw ImageStoreError.unableToConverToData }
		let dir = url.deletingLastPathComponent()
		try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
		try data.write(to: url, options: [.atomic])
	}

	convenience init?(contentsOf url: URL) {
		guard let data = try? Data(contentsOf: url), data.count != 0 else {
			self.init()
			return nil
		}
		
		self.init(data: data)
	}
	
	class func create(size: CGSize, closure: (CGContext) -> Void) -> UIImage? {
		if #available(iOS 10.0, iOSApplicationExtension 10.0, *) {
			return UIGraphicsImageRenderer(size: size).image { renderer in
				guard let ctx = UIGraphicsGetCurrentContext() else {
					dlog("UIGraphicsGetCurrentContext() Failed")
					return
				}
				
				closure(ctx)
			}
		} else {
			UIGraphicsBeginImageContextWithOptions(size, false, 0)
			guard let ctx = UIGraphicsGetCurrentContext() else {
				dlog("UIGraphicsGetCurrentContext() Failed")
				return nil
			}

			closure(ctx)
			let image = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return image
		}
	}
	
	func tintedImage(tint: UIColor) -> UIImage? {
		let frame = self.size.rect
		
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		self.draw(in: frame)
		tint.setFill()
		UIRectFillUsingBlendMode(frame, CGBlendMode.sourceIn)
		let result = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return result
	}
	
	func scaledImage(scale: CGFloat) -> UIImage {
		if scale == 1.0 { return self }
		if let cgImage = self.cgImage {
			return UIImage(cgImage: cgImage, scale: 1 / scale, orientation: .up)
		}
		return self
	}
	
	func resizedImage(size: CGSize, trimmed: Bool = true, changeScaleTo: CGFloat? = nil) -> UIImage? {
		var frame = self.size.rect.within(limit: size.rect, placed: .scaleAspectFit).round()

		if frame.origin.x > 0 {
			frame.origin.x = 0;
			if (!trimmed) { frame.size.width = size.width; }
		} else {
			frame.origin.y = 0;
			if (!trimmed) { frame.size.height = size.height; }
		}
		
		let scale = changeScaleTo ?? UIScreen.main.scale
		UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
		
		self.draw(in: frame)
		
		let result = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return result
	}
	
	var hasAlpha: Bool {
		guard let cg = self.cgImage else { return false }
		
		let alpha = cg.alphaInfo
		
		return (alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast)
	}

}

public extension UIImage {
	static func randomEmojiImage(face: Bool = false, ofSize size: CGSize, background color: UIColor = .white) -> UIImage? {
		return UIGraphicsImageRenderer(size: size).image { ctx in
			let str = NSAttributedString(string: String.randomEmoji(facesOnly: face), attributes: [.font: UIFont.systemFont(ofSize: size.height * 0.8)])
			let strSize = str.size()
			color.setFill()
			UIRectFill(size.rect)
			str.draw(in: CGRect(x: (size.width - strSize.width) / 2, y: (size.height - strSize.height) / 2, width: strSize.width, height: strSize.height))
		}
	}
}
#endif
