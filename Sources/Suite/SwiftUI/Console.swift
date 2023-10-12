//
//  Console.swift
//  Prometheus5
//
//  Created by Ben Gottlieb on 10/8/23.
//

import SwiftUI

public class Console: ObservableObject {
	public static let instance = Console()
	var messages: [String] = []
	
	public static func print(_ content: String) {
		instance.print(content)
	}
	
	public func print(_ content: String) {
		messages.append(content)
		objectWillChange.sendOnMain()
	}
}

public struct ConsoleView: View {
	@ObservedObject var console = Console.instance
	
	public init() { }
	public var body: some View {
		VStack {
			Spacer()
			
			if let last = console.messages.last {
				Text(last)
					.font(.caption)
					.frame(maxWidth: .infinity)
					.background(Color.white)
					.foregroundColor(.black)
					.padding(2)
					.border(.black, width: 2)
					.padding()
			}
		}
	}
}
