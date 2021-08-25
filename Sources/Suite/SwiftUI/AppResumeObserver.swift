//
//  AppResumeObserver.swift
//  
//
//  Created by Ben Gottlieb on 8/25/21.
//

#if canImport(Combine)
import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, watchOS 6.0, *)
public class AppResumeObserver: ObservableObject {
	public static let instance = AppResumeObserver()

	var cancellable: AnyCancellable?

	init() {
		cancellable = UIApplication.willEnterForegroundNotification.publisher()
			.sink { _ in
				self.objectWillChange.send()
			}
	}
}
#endif
