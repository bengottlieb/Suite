//
//  HostingWindow.swift
//  
//
//  Created by Ben Gottlieb on 1/12/21.
//

#if canImport(AppKit)
#if canImport(SwiftUI)

#if !targetEnvironment(macCatalyst)

import SwiftUI
import AppKit

typealias WindowFetcher = () -> NSWindow?

@available(OSX 10.15, *)
struct HostingWindowKey: EnvironmentKey {
	static let defaultValue: WindowFetcher = { nil }
}

@available(OSX 10.15, *)
extension EnvironmentValues {
	 public var hostingWindow: NSWindow? {
		  get {
				return self[HostingWindowKey.self]()
		  }
		  set {
				self[HostingWindowKey.self] = { [weak newValue] in newValue }
		  }
	 }
}

@available(OSX 10.15, *)
public class HostingWindow<Root: View>: NSWindow {
    var onClose: (() -> Void)?
    public init(root: Root, title: String? = nil, background: NSColor = .windowBackgroundColor, onClose: (() -> Void)? = nil) {
        var flags: NSWindow.StyleMask = [.fullSizeContentView]
        
        if title != nil {
            flags.insert([.titled, .closable, .miniaturizable, .resizable])
        }
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: flags,
            backing: .buffered, defer: false)
        
        self.backgroundColor = background
        self.isReleasedWhenClosed = false
        self.center()
        if let title = title {
            self.setFrameAutosaveName(title)
            self.title = title
        }
        self.onClose = onClose
        self.contentView = NSHostingView(rootView: root
											.environment(\.hostingWindow, self))
    }
    
    
    public override func performClose(_ sender: Any?) {
        super.performClose(sender)
        self.onClose?()
    }
}




#endif
#endif
#endif
