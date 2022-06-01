//
//  ObservableObserver.swift
//  
//
//  Created by Ben Gottlieb on 6/1/22.
//

#if canImport(Combine)

import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public class ObservableObserver<Target: ObservableObject>: ObservableObject {
   private var lastValue: Bool
   private var check: () -> Bool
   private var cancellable: AnyCancellable?
   
   public init(target: Target, check: @escaping () -> Bool) {
      self.check = check
      lastValue = check()
      cancellable = target.objectWillChange.sink { _ in
         self.update()
      }
   }
   
   func update() {
      let newValue = check()
      if newValue != lastValue {
         lastValue = newValue
         objectWillChange.send()
      }
   }
}

#endif
