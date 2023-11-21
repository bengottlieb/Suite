//
//  UIViewController.swift
//  
//
//  Created by Ben Gottlieb on 12/1/19.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

#if !os(visionOS)
public extension UIViewController {
	class func fromStoryboard(_ name: String? = nil, bundle: Bundle? = nil) -> Self {
		let storyboardName = name ?? NSStringFromClass(self).components(separatedBy: ".").last!
		return self.fromStoryboard(class: self, name: storyboardName, bundle: bundle ?? Bundle(for: self))
	}
	
	class func fromStoryboard<T: UIViewController>(class: T.Type, name: String, bundle: Bundle?) -> T {
		let storyboard = UIStoryboard(name: name, bundle: bundle ?? Bundle(for: self))
		
		let controller = storyboard.instantiateInitialViewController()
		return controller as! T
	}
	
	class func fromXIB(_ nibName: String? = nil, bundle: Bundle? = nil) -> Self {
		let bndle = Bundle(for: self)
		return self.init(nibName: nibName ?? self.nibName, bundle: bndle)
	}
	
	class func controller() -> Self {
		return self.fromXIB()
	}
	
	class var nibName: String? {
		let type = "\(NSStringFromClass(self))"
		let comp = type.components(separatedBy: ".")
		let filename = comp.last
		
		if Bundle(for: self).url(forResource: filename, withExtension: "nib") !=  nil { return filename }
		return nil
	}
}
#endif

public extension UIViewController {
	var isInDarkMode: Bool { return self.traitCollection.isInDarkMode }
	
	@discardableResult
	func turnOffCardModalPresentation() -> Self {
		if #available(iOS 13.0, iOSApplicationExtension 13.0, *) {
			self.isModalInPresentation = true
			self.modalPresentationStyle = .fullScreen
		}
		return self
	}
	
	var presentedest: UIViewController {
		return self.presentedViewController?.presentedest ?? self
	}
	
	var container: UIViewController {
		return self.parent ?? self.navigationController ?? self.tabBarController ?? self.splitViewController ?? self
	}
}

@available(iOSApplicationExtension, unavailable)
public extension UIViewController {
	func share(something: [Any], fromItem barButtonItem: UIBarButtonItem? = nil, fromView: UIView? = nil, position: CGRect.Placement = .topRight) {
		guard !something.isEmpty else { return }
		let activityVC = UIActivityViewController(activityItems: something, applicationActivities: nil)
		if let barButtonItem = barButtonItem {
			activityVC.popoverPresentationController?.barButtonItem = barButtonItem
		} else if let view = fromView {
			activityVC.popoverPresentationController?.sourceView = view
			activityVC.popoverPresentationController?.sourceRect = view.bounds
		} else if let root = UIApplication.shared.currentWindow?.rootViewController?.presentedest.view {
			activityVC.popoverPresentationController?.sourceView = root
			activityVC.popoverPresentationController?.sourceRect = CGRect.zero.within(limit: root.frame, placed: position)
			
		}
		self.present(activityVC, animated: true, completion: nil)
	}
}
#endif
