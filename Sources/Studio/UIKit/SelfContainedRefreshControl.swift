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
	
	public convenience init(closure: @escaping (@escaping () -> Void) -> Void) {
		self.init()
		
		self.closure = closure
		addTarget(self, action: #selector(refreshed), for: .valueChanged)
	}
	
	@objc func refreshed() {
		closure?() { [ weak self] in
			DispatchQueue.main.async { self?.endRefreshing() }
		}
	}
}
#endif
