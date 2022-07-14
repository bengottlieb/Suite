//
//  UICollectionView.swift
//  
//
//  Created by Ben Gottlieb on 2/22/20.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit


extension UICollectionViewCell {
	public class var identifier: String { return String(describing: self) }
	public class var nib: UINib { return UINib(nibName: self.defaultNibName, bundle: Bundle(for: self)) }
	public class var defaultNibName: String { return String(describing: self) }
}

extension UICollectionView {
	public func register(cellClass: UICollectionViewCell.Type) {
		self.register(cellClass.nib, forCellWithReuseIdentifier: cellClass.identifier)
	}
	
	@discardableResult
	public func delegate(_ delegate: UICollectionViewDelegate) -> Self {
		self.delegate = delegate
		return self
	}
	
	@discardableResult
	public func dataSource(_ dataSource: UICollectionViewDataSource) -> Self {
		self.dataSource = dataSource
		return self
	}
}
#endif
