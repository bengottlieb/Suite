//
//  Gestalt+watchOS.swift
//  
//
//  Created by Ben Gottlieb on 5/30/22.
//

#if os(watchOS)
import Foundation
import WatchKit

public extension Gestalt {
	enum WatchCaseSize: Int { case watch38mm = 38, watch40mm = 40, watch41mm = 41, watch42mm = 42, watch44mm = 44, watch45mm = 45, larger = 100 }
	
	static var caseSize: WatchCaseSize {
		if let raw = modelName.components(separatedBy: " ").last?.trimmingCharacters(in: .init(charactersIn: "m")), let size = Int(raw), let caseSize = WatchCaseSize(rawValue: size) { return caseSize }
		
		switch WKInterfaceDevice.current().screenBounds.size {
		case CGSize(width: 136, height: 170): return .watch38mm
		case CGSize(width: 162, height: 197): return .watch40mm
		case CGSize(width: 176, height: 215): return .watch41mm
		case CGSize(width: 156, height: 195): return .watch42mm
		case CGSize(width: 184, height: 224): return .watch44mm
		case CGSize(width: 198, height: 242): return .watch45mm
		default: return .larger
		}
	}

	static var isOnMac: Bool { return false }
}

#endif
