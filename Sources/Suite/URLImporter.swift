//
//  URLImporter.swift
//  
//
//  Created by Ben Gottlieb on 12/1/20.
//

import Foundation
import SwiftUI

/*

	Call .queue(url) from either:

	AppKit: UISceneDelegate.scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>)

			or
	
	SwiftUI: Scene.onOpenURL() { url in }

*/

open class URLImporter {

	public init() { }
	
	public enum State { case idle, importing }
	
	weak var importTimer: Timer?
	var pendingURLs: [URL] = []
	var state = State.idle { didSet { self.startImportTimer() }}
	
	public static var importDirectoryName = "Imported Files"
	
	var importDirectory: URL = {
		let url = FileManager.libraryDirectory.appendingPathComponent(URLImporter.importDirectoryName)
		try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
		return url
	}()
	
	public func queue(_ urls: [URL]) {
		urls.forEach { addOne(url: $0) }
		startImportTimer()
	}

	
	public func queue(_ url: URL) {
		self.addOne(url: url)
		startImportTimer()
	}
	
	func addOne(url: URL) {
		let newURL = availableFilename(startingWith: url.deletingPathExtension().lastPathComponent, extension: url.pathExtension)
		
		do {
			try FileManager.default.moveItem(at: url, to: newURL)
		
			pendingURLs.append(newURL)
		} catch {
			log(error: error, "Problem copying \(url) to \(newURL)")
		}
	}
	
	public func completeImport(of urls: [URL]) {
		self.state = .idle
		urls.forEach { try? FileManager.default.removeItem(at: $0) }
	}
	
	open func availableFilename(startingWith name: String, extension ext: String) -> URL {
		var base = name
		var count = 1
		while true {
			let url = importDirectory.appendingPathComponent(base).appendingPathExtension(ext)
			if !FileManager.default.fileExists(at: url) { return url }
			count += 1
			base = name + " \(count)"
		}
	}
	
	func startImportTimer() {
		importTimer?.invalidate()

		if state != .idle || pendingURLs.isEmpty { return }
		
		importTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
			let urls = self.pendingURLs
			self.state = .importing
			self.pendingURLs = []
			self.performImport(of: urls)
		}
	}
	
	open func performImport(of urls: [URL]) {

	}
}
