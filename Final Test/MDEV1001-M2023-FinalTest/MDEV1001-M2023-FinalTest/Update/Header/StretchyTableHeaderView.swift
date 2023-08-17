//
//  StretchyTableHeaderView.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import UIKit
import SDWebImage

final class StretchyTableHeaderView: UIView {
    
    private var containerViewHeight = NSLayoutConstraint()
    private var imageViewHeight = NSLayoutConstraint()
    private var imageViewBottom = NSLayoutConstraint()
    
    private var containerView: UIView!
    private var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
}

// MARK: - Exposed Helpers
extension StretchyTableHeaderView {
    
    func setImage(with imageUrl: URL?, isAnimated: Bool) {
        guard isAnimated else {
            imageView.sd_setImage(with: imageUrl)
            return
        }
        UIView.transition(with: imageView, duration: Constants.animationDuration, options: .transitionCurlUp) { [weak self] in
            self?.setImage(with: imageUrl, isAnimated: false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        containerViewHeight.constant = scrollView.contentInset.top
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        containerView.clipsToBounds = offsetY <= 0
        imageViewBottom.constant = offsetY >= 0 ? 0 : -offsetY / 2
        imageViewHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
    }
    
}

// MARK: - Private Helpers
private extension StretchyTableHeaderView {
    
    func setup() {
        containerView = UIView()
        addSubview(containerView)
        imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        containerView.addSubview(imageView)
        setConstraints()
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: containerView.widthAnchor),
            centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        containerViewHeight = containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        containerViewHeight.isActive = true
        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageViewBottom = imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        imageViewBottom.isActive = true
        imageViewHeight = imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        imageViewHeight.isActive = true
    }
    
}
