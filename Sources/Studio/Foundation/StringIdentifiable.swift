//
//  File.swift
//  
//
//  Created by ben on 11/6/20.
//

import Foundation

#if canImport(Combine)
	
	public protocol StringIdentifiable: Identifiable where ID: StringProtocol {
	}

#else

	public protocol StringIdentifiable: Identifiable {
		var id: String { get }
	}

#endif
