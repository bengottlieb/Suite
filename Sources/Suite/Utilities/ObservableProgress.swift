//
//  ObservableProgress.swift
//  
//
//  Created by Ben Gottlieb on 8/1/20.
//

import SwiftUI


@available(iOS 13.0, macOS 10.15, *)
public class ObservableProgress: ObservableObject {
	@Published public var progress: Progress?
	
	public init(_ progress: Progress? = nil) {
		self.progress = progress
	}
	
	public var completedUnitCount: Int64 {
		get { progress?.completedUnitCount ?? 0 }
		set { progress?.completedUnitCount = newValue; objectWillChange.send() }
	}

	public var totalUnitCount: Int64 {
		get { progress?.totalUnitCount ?? 0 }
		set { progress?.totalUnitCount = newValue; objectWillChange.send() }
	}
	
	public var fractionCompleted: Double {
		get { progress?.fractionCompleted ?? 0.0 }
		set { completedUnitCount = Int64(Double(totalUnitCount) * newValue) }
	}
	
	public func setFractionCompleted(_ fraction: Double) {
		DispatchQueue.main.async { self.fractionCompleted = fraction }
	}
	
	public var isIndeterminate: Bool { progress == nil }
}
