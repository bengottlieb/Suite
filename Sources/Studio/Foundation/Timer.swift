//
//  Timer.swift
//  
//
//  Created by Ben Gottlieb on 8/12/23.
//

#if canImport(Combine)
import Combine
import Foundation

public typealias AutoconnectedTimer = Publishers.Autoconnect<Timer.TimerPublisher>

public extension Timer {
	static func nonPausingTimer(withTimeInterval interval: TimeInterval, block: @escaping @Sendable (Timer) -> Void) -> Timer {
		let timer = Timer(timeInterval: interval, repeats: true, block: block)
		
		RunLoop.main.add(timer, forMode: .common)
		
		return timer
	}
}

#endif
