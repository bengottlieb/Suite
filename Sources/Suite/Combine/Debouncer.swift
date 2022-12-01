//
//  Debouncer.swift
//  
//
//  Created by Ben Gottlieb on 11/28/22.
//

import Foundation
import Combine

public class Debouncer<Value>: ObservableObject {
	@Published public var input: Value
	@Published public var output: Value
	
	private var debounce: AnyCancellable?
	
	public init(initialValue: Value, delay: Double = 1) {
		self.input = initialValue
		self.output = initialValue
		debounce = $input
			.debounce (for: . seconds (delay), scheduler: DispatchQueue.main)
			.sink { [weak self] in
				self?.output = $0
			}
	}
}
