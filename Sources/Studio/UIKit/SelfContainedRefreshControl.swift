//
//  SelfContainedRefreshControl.swift
//  
//
//  Created by Ben Gottlieb on 5/23/21.
//

#if os(iOS)
import UIKit

public class SelfContainedRefreshControl: UIRefreshControl {
	var closure: ((@escaping () -> Void) -> Void)?
	var delay: TimeInterval = 0.3
	
	public convenience init(delay: TimeInterval = 0.3, closure: @escaping (@escaping () -> Void) -> Void) {
		self.init()
		
		self.closure = closure
		self.delay = delay
		addTarget(self, action: #selector(refreshed), for: .valueChanged)
	}
	
	@objc func refreshed() {
		closure?() { [ weak self] in
			DispatchQueue.main.async(after: self?.delay ?? 0) { self?.endRefreshing() }
		}
	}
}

@available(iOS 10.0, *)
public extension UIScrollView {
	func addRefreshControl(delay: TimeInterval = 0.3, calling: @escaping (@escaping () -> Void) -> Void) {
		if let refresh = self.refreshControl as? SelfContainedRefreshControl {
			refresh.closure = calling
			refresh.delay = delay
		} else {
			self.refreshControl = SelfContainedRefreshControl(delay: delay, closure: calling)
		}
	}
}
#endif
