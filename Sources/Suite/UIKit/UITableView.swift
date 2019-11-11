//
//  UITableView.swift
//  
//
//  Created by Ben Gottlieb on 11/10/19.
//
import UIKit

extension UITableViewCell {
	open class var identifier: String { return String(describing: self) }
	open class var nib: UINib { return UINib(nibName: self.defaultNibName, bundle: Bundle(for: self)) }
	open class var defaultNibName: String { return String(describing: self) }
    
    static let separatorTag = 1001
}

extension UITableView {
	public func register(cellClass: UITableViewCell.Type) {
		self.register(cellClass.nib, forCellReuseIdentifier: cellClass.identifier)
	}

    /// dequeue unregistered cell
    func dequeueCell<T>(type: T.Type) -> T where T: UITableViewCell {
        let typeName = T.identifier
        return self.dequeueReusableCell(withIdentifier: typeName) as? T ??
            type.init(style: .default, reuseIdentifier: typeName)
    }

    // dequeue registered cell
    func dequeueCell<T>(type: T.Type, indexPath: IndexPath) -> T where T: UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }

    /// dequeue plain `UITableViewCell`
    func dequeuePlainCell(identifier: String) -> UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
    }
}
