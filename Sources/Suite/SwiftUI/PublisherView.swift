//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 3/16/21.
//


#if canImport(Combine)
import SwiftUI
import Combine

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public struct PublisherView<Definition, Content: View>: View {
	let content: (Definition?) -> Content
	let pub: AnyPublisher<Definition?, Never>
	
	@State var data: Definition?
	
	public init(_ pub: AnyPublisher<Definition, Never>, defaultValue: Definition? = nil, content: @escaping (Definition?) -> Content) {
		self.content = content
		self.pub = pub.map { (input: Definition) -> Definition? in input }.eraseToAnyPublisher()
		_data = State(initialValue: defaultValue)
	}
	
	public init(_ pub: AnyPublisher<Definition?, Never>, defaultValue: Definition? = nil, content: @escaping (Definition?) -> Content) {
		self.content = content
		self.pub = pub.eraseToAnyPublisher()
		_data = State(initialValue: defaultValue)
	}

	public var body: some View {
		content(data)
			.onReceive(pub.receive(on: RunLoop.main)) { result in
				data = result
			}
	}
}
#endif
