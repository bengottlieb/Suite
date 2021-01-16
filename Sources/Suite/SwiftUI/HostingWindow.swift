//
//  HostingWindow.swift
//  
//
//  Created by Ben Gottlieb on 1/12/21.
//

#if canImport(AppKit)

import SwiftUI
import AppKit


@available(OSX 10.15, *)
public class HostingWindow<Root: View>: NSWindow {
    public init(root: Root, title: String? = nil, background: NSColor = .windowBackgroundColor) {
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
        self.contentView = NSHostingView(rootView: root)
    }
}




#endif
