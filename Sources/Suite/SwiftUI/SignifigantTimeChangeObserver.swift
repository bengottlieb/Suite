//
//  SignifigantTimeChangeObserver.swift
//  Strongest
//
//  Created by Ben Gottlieb on 8/24/21.
//  Copyright © 2021 Strongest AI, Inc. All rights reserved.
//

#if canImport(Combine)
import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public class SignifigantTimeChangeObserver: ObservableObject {
	public static let instance = SignifigantTimeChangeObserver()

	var cancellable: AnyCancellable?

	init() {
		cancellable = UIApplication.significantTimeChangeNotification.publisher()
			.sink { _ in
				self.objectWillChange.send()
			}
	}
}
#endif
