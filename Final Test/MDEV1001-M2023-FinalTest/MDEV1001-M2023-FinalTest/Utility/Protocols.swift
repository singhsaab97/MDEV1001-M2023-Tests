//
//  Protocols.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import UIKit

protocol ViewLoadable {
    static var name: String { get }
    static var identifier: String { get }
}

protocol CellViewModelable {}

protocol Toastable {}

extension ViewLoadable where Self: UIViewController {
    
    static func loadFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }
    
}

extension ViewLoadable where Self: UIView {
    
    static func loadFromNib() -> Self {
        let nib = UINib(nibName: name, bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as! Self
    }
    
}

extension ViewLoadable where Self: UITableViewCell {
    
    static func register(for tableView: UITableView) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    static func dequeReusableCell(from tableView: UITableView, at indexPath: IndexPath) -> Self {
        return tableView.dequeueReusableCell(
            withIdentifier: identifier,
            for: indexPath
        ) as! Self
    }
    
}

extension ViewLoadable where Self: UICollectionViewCell {
    
    static func register(for collectionView: UICollectionView) {
        let nib = UINib(nibName: name, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    static func dequeReusableCell(from collectionView: UICollectionView, at indexPath: IndexPath) -> Self {
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: identifier,
            for: indexPath
        ) as! Self
    }
    
}

extension Toastable {
    
    func showToast(with message: String) {
        guard let window = UIApplication.shared.windows.first,
              !window.subviews.contains(where: { $0 is ToastView }) else { return }
        // Don't add another toast if one already exists
        let view = ToastView.loadFromNib()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setMessage(message)
        view.layer.cornerRadius = 12
        view.alpha = .zero
        window.addSubview(view)
        var bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        bottomInset = bottomInset.isZero ? 20 : bottomInset
        view.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -bottomInset).isActive = true
        view.widthAnchor.constraint(lessThanOrEqualTo: window.widthAnchor, constant: 40).isActive = true
        view.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        // Animate
        UIView.animate(withDuration: Constants.animationDuration) { [weak view] in
            view?.alpha = 1
            // Disapeear after a few seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.toastDisplayDuration) { [weak view] in
                UIView.animate(withDuration: Constants.animationDuration) { [weak view] in
                    view?.alpha = .zero
                } completion: { [weak view] _ in
                    view?.removeFromSuperview()
                }
            }
        }
    }
    
}
