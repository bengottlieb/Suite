//
//  App+Extension.swift
//  
//
//  Created by Ben Gottlieb on 1/10/21.
//

#if canImport(SwiftUI)
#if canImport(Combine)
import SwiftUI
import Combine

@available(OSX 10.16, iOS 14.0, tvOS 13, watchOS 7, *)
public enum AppRunMode: String { case app, widget, siri, `extension`, watch }

#endif
#endif
