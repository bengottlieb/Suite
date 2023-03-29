//
//  Box.swift
//  
//
//  Created by Ben Gottlieb on 3/29/23.
//

import Foundation


public class Box<Contents> {
	public var contents: Contents
	
	public init(contents: Contents) {
		self.contents = contents
	}
}

public class IDBox<Contents, ID: Equatable>: Equatable {
	public var contents: Contents
	public let id: ID
	
	public init(contents: Contents, id: ID) {
		self.contents = contents
		self.id = id
	}
	
	public static func ==(lhs: IDBox, rhs: IDBox) -> Bool {
		lhs.id == rhs.id
	}
}

extension IDBox where ID == String {
	public convenience init(contents: Contents) {
		self.init(contents: contents, id: UUID().uuidString)
	}
}




