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
public struct PublisherView<Kind, Content: View>: View {
	let content: (Kind?) -> Content
	let pub: AnyPublisher<Kind?, Never>
	
	@State var data: Kind?
	
	public init(_ pub: AnyPublisher<Kind, Never>, defaultValue: Kind? = nil, content: @escaping (Kind?) -> Content) {
		self.content = content
		self.pub = pub.map { (input: Kind) -> Kind? in input }.eraseToAnyPublisher()
		_data = State(initialValue: defaultValue)
	}
	
	public init(_ pub: AnyPublisher<Kind?, Never>, defaultValue: Kind? = nil, content: @escaping (Kind?) -> Content) {
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
