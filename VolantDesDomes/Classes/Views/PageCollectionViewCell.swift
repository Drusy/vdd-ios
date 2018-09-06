//
//  PageCollectionViewCell.swift
//  VolantDesDomes
//
//  Created by Drusy on 31/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit

class PageCollectionViewCell: UICollectionViewCell, CellIdentifiable {

    @IBOutlet weak var pageImageView: UIImageView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var roundedView: UIView!
    
    override var isHighlighted: Bool {
        didSet {
            let transformation = isHighlighted ? CGAffineTransform.init(scaleX: 0.95, y: 0.95) : .identity
            
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.beginFromCurrentState],
                animations: { [weak self] in
                    self?.shadowView.transform = transformation
                },
                completion: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundedView.layer.cornerRadius = 4
        roundedView.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        pageImageView.kf.cancelDownloadTask()
        shadowView.transform = .identity
    }
    
    // MARK: -
    
    func configure(with page: PageItem) {
        pageTitleLabel.text = page.title
        pageImageView.image = page.image
    }
}
