//
//  UITableView.swift
//  
//
//  Created by Ben Gottlieb on 11/10/19.
//
#if canImport(UIKit) && !os(watchOS)
import UIKit

extension UITableViewCell {
	public class var identifier: String { return String(describing: self) }
	public class var nib: UINib { return UINib(nibName: self.defaultNibName, bundle: Bundle(for: self)) }
	public class var defaultNibName: String { return String(describing: self) }
}

extension UITableView {
	public func register(cellClass: UITableViewCell.Type) {
		self.register(cellClass.nib, forCellReuseIdentifier: cellClass.identifier)
	}

    func dequeueCell<T>(type: T.Type) -> T where T: UITableViewCell {
        let typeName = T.identifier
        return self.dequeueReusableCell(withIdentifier: typeName) as? T ??
            type.init(style: .default, reuseIdentifier: typeName)
    }

    func dequeueCell<T>(type: T.Type, indexPath: IndexPath) -> T where T: UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }

    /// dequeue plain `UITableViewCell`
    func dequeuePlainCell(identifier: String) -> UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
    }
	
	@discardableResult
	public func delegate(_ delegate: UITableViewDelegate) -> Self {
		self.delegate = delegate
		return self
	}
	
	@discardableResult
	public func dataSource(_ dataSource: UITableViewDataSource) -> Self {
		self.dataSource = dataSource
		return self
	}
}
#endif
