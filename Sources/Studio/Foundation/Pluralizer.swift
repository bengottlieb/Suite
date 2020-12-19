//
//  Pluralizer.swift
//  
//
//  Created by Ben Gottlieb on 12/18/20.
//

import Foundation


public class Pluralizer {
	public static let instance = Pluralizer()
	
	init() {
		
	}
	
	var plurals: [String: String] = [:]
	
	public func pluralize(_ count: Int, _ singular: String, spelledOut: Bool = false) -> String {
		if count == 1 { return "1 " + singular }
		return "\(count) \(self[singular])"
	}
	
	public subscript(singular: String) -> String {
		get {
			if let plural = plurals[singular.lowercased()] { return plural }
			
			if singular.hasSuffix("s") { return singular }
			return singular + "s"
		}
		
		set {
			plurals[singular.lowercased()] = newValue
		}
	}
}
