//
//  NSManagedObject+Background.swift
//  
//
//  Created by ben on 2/2/21.
//

import Foundation
import CoreData

public extension NSManagedObject {
	@discardableResult
	func onBackground<Object: NSManagedObject>(perform: @escaping (NSManagedObjectContext, Object) -> Void) -> Bool {
		guard let myContext = self.moc else { return false }
		let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		moc.parent = myContext
		
		guard let obj = moc.instantiate(self) as? Object else { return false }
		
		moc.perform {
			perform(moc, obj)
		}
		return true
	}
}
