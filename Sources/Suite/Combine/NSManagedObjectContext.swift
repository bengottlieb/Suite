//
//  NSManagedObjectContext.swift
//  
//
//  Created by Ben Gottlieb on 7/16/20.
//

#if canImport(Combine)
import Foundation
import CoreData
import Combine


@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
extension NSManagedObjectContext {
	public func publish<T>(block: @escaping (NSManagedObjectContext) throws -> T) -> AnyPublisher<T, Error> {
		let future = Future<T,Error>() { promise in
			do {
				let result = try block(self)
				promise(.success(result))
			} catch {
				promise(.failure(error))
			}
		}
		
		return future.eraseToAnyPublisher()
	}

	func publish<T>(block: @escaping (NSManagedObjectContext) -> AnyPublisher<T, Error>) -> AnyPublisher<T, Error> {
		block(self)
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
public extension NSManagedObjectContext {
	static let PublishersKey: StaticString = "__PublishersKey"
	func publisher<Entity: NSManagedObject>(for request: NSFetchRequest<Entity>) -> AnyPublisher<[Entity], Never> {
		let pub = FetchedResultsControllerPublisher(request: request, in: self)
		
		if let array = self.associatedObject(forKey: Self.PublishersKey) as? NSMutableArray {
			array.add(pub)
		} else {
			let newArray = NSMutableArray(array: [pub])
			self.associate(object: newArray, forKey: Self.PublishersKey)
		}
		
		return pub
			.publisher
			.eraseToAnyPublisher()
	}
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
final public class FetchedResultsControllerPublisher<FetchType>: NSObject where FetchType : NSFetchRequestResult & Hashable {
	private let internalController: FetchedResultsControllerPublisherInternal<FetchType>
	
	public init(request: NSFetchRequest<FetchType>, in moc: NSManagedObjectContext, performFetch: Bool = true) {
		let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
		self.internalController = FetchedResultsControllerPublisherInternal(fetchedResultsController: controller, performFetch: performFetch)
		super.init()
	}
	
	public lazy var publisherWithErrors: AnyPublisher<[FetchType], Error> = {
		return self.internalController.publisher.eraseToAnyPublisher()
	}()
	
	public lazy var publisher: AnyPublisher<[FetchType], Never> = {
		return self.internalController.publisher.replaceError(with: []).eraseToAnyPublisher()
	}()
}

@available(OSX 10.15, iOS 13.0, tvOS 13, watchOS 6, *)
final private class FetchedResultsControllerPublisherInternal<FetchType> : NSObject, NSFetchedResultsControllerDelegate where FetchType : NSFetchRequestResult & Hashable {
	let publisher: PassthroughSubject<[FetchType], Error>
	let fetchedResultsController: NSFetchedResultsController<FetchType>
	var lastHashSent = 0
	
	init(fetchedResultsController: NSFetchedResultsController<FetchType>, performFetch: Bool) {
		self.fetchedResultsController = fetchedResultsController
		publisher = PassthroughSubject<[FetchType], Error>()
		super.init()
		fetchedResultsController.delegate = self
		fetchedResultsController.managedObjectContext.perform {
			do {
				if performFetch {
					try fetchedResultsController.performFetch()
				}
				self.publisher.send(fetchedResultsController.fetchedObjects ?? [])
			} catch {
				self.publisher.send(completion: .failure(error))
			}
		}
	}
	
	@objc func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		let newHash = fetchedResultsController.fetchedObjects?.hashValue ?? 0
		if newHash == lastHashSent { return }
		
		lastHashSent = newHash
		publisher.send(fetchedResultsController.fetchedObjects ?? [])
	}
}

#endif
