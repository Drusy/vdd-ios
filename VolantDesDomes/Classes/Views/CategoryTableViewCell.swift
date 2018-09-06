//
//  CategoryTableViewCell.swift
//  VolantDesDomes
//
//  Created by Drusy on 24/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import Kingfisher

class CategoryTableViewCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var backgroundImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    let imageParallaxFactor: CGFloat = 50
    var backgroundImageTopInitial: CGFloat?
    var backgroundImageBottomInitial: CGFloat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundedView.layer.cornerRadius = 6
        roundedView.layer.masksToBounds = true
        roundedView.clipsToBounds = true
        
        backgroundImageBottomConstraint.constant -= 2 * imageParallaxFactor
        backgroundImageTopInitial = backgroundImageTopConstraint.constant
        backgroundImageBottomInitial = backgroundImageBottomConstraint.constant
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backgroundImageView.kf.cancelDownloadTask()
        shadowView.transform = .identity
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let transformation = highlighted ? CGAffineTransform.init(scaleX: 0.95, y: 0.95) : .identity
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.beginFromCurrentState],
            animations: { [weak self] in
                self?.shadowView.transform = transformation
            },
            completion: nil)
    }
    
    // MARK: -
    
    func configure(with category: WPCategory) {
        titleLabel.text = category.name
        subtitleLabel.text = category.desc
        
        if let featuredMediaLink = category.featuredMedia?.large, let url = URL(string: featuredMediaLink) {
            backgroundImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        } else if let slug = category.slug, let slugImage = UIImage(named: slug) {
            backgroundImageView.image = slugImage
        } else {
            backgroundImageView.image = #imageLiteral(resourceName: "placeholder")
        }
    }
    
    func setBackground(offset: CGFloat) {
        guard let top = backgroundImageTopInitial else { return }
        guard let bottom = backgroundImageBottomInitial else { return }

        let boundOffset = max(0, min(1, offset))
        let pixelOffset = (1 - boundOffset) * 2 * imageParallaxFactor
        
        backgroundImageTopConstraint.constant = top - pixelOffset
        backgroundImageBottomConstraint.constant = bottom + pixelOffset
    }
}
