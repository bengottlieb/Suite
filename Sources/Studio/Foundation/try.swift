//
//  tryLog.swift
//  
//
//  Created by ben on 9/4/20.
//

import Foundation

public func tryLog<T>(_ closure: @autoclosure () throws -> T) -> T? {
	do {
		return try closure()
	} catch {
		logg("\(error)")
		return nil
	}
}
