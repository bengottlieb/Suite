//
//  NSManagedObjectContext.swift
//  
//
//  Created by Ben Gottlieb on 7/16/20.
//

import Foundation
import CoreData
import Combine
import Studio

#if canImport(Combine)


@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension NSManagedObjectContext {
	func publisher<Entity: NSManagedObject>(for request: NSFetchRequest<Entity>) -> AnyPublisher<[Entity], Never> {
		RequestPublisher(request: request, context: self)
			.eraseToAnyPublisher()
	}
	
	class RequestPublisher<Entity: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate, Publisher {
		public typealias Output = [Entity]
		public typealias Failure = Never
		
		private let request: NSFetchRequest<Entity>
		private let context: NSManagedObjectContext
		private let subject: CurrentValueSubject<[Entity], Failure>
		private var resultController: NSFetchedResultsController<Entity>?
		private var subscriptions = 0
		
		init(request: NSFetchRequest<Entity>, context: NSManagedObjectContext) {
			if request.sortDescriptors == nil { request.sortDescriptors = [] }
			self.request = request
			self.context = context
			subject = CurrentValueSubject([])
			super.init()
		}
		
		public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == RequestPublisher.Failure, S.Input == RequestPublisher.Output {
			var isNewSubscription = false
			
			DispatchQueue.isolated("requestPublisher") {
				self.subscriptions += 1
				if self.subscriptions == 1 { isNewSubscription = true }
			}
			
			if isNewSubscription {
				let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
				controller.delegate = self
				
				do {
					try controller.performFetch()
					let result = controller.fetchedObjects ?? []
					subject.send(result)
				} catch {
					_ = print("Got an error when fetching: \(error)")
				}
				resultController = controller
			}
			
			RequestSubscription(fetchPublisher: self, subscriber: AnySubscriber(subscriber))
		}
		
		public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
			let result = controller.fetchedObjects as? [Entity] ?? []
			subject.send(result)
		}
		
		private func dropSubscription() {
			var isLastSubscription = false
			DispatchQueue.isolated("requestPublisher") {
				subscriptions -= 1
				isLastSubscription = subscriptions == 0
			}
			
			if isLastSubscription {
				resultController?.delegate = nil
				resultController = nil
			}
		}
		
		private class RequestSubscription: Subscription {
			private var fetchPublisher: RequestPublisher?
			private var cancellable: AnyCancellable?
			
			@discardableResult
			init(fetchPublisher: RequestPublisher, subscriber: AnySubscriber<Output, Failure>) {
				self.fetchPublisher = fetchPublisher
				
				subscriber.receive(subscription: self)
				
				cancellable = fetchPublisher.subject.sink(receiveCompletion: { completion in
					subscriber.receive(completion: completion)
				}, receiveValue: { value in
					_ = subscriber.receive(value)
				})
			}
			
			func request(_ demand: Subscribers.Demand) {}
			
			func cancel() {
				cancellable?.cancel()
				cancellable = nil
				fetchPublisher?.dropSubscription()
				fetchPublisher = nil
			}
		}
		
	}
}

#endif
