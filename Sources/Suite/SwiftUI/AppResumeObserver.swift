//
//  AppResumeObserver.swift
//  
//
//  Created by Ben Gottlieb on 8/25/21.
//

#if canImport(Combine)
#if canImport(UIKit)
import UIKit
import Combine

#if os(iOS)
@available(iOS 13.0, *)
public class AppResumeObserver: ObservableObject {
	public static let instance = AppResumeObserver()

	var cancellable: AnyCancellable?

	init() {
		cancellable = UIApplication.willEnterForegroundNotification.publisher()
			.sink { _ in
				DispatchQueue.main.async { self.objectWillChange.send() }
			}
	}
}
#endif
#endif
#endif
