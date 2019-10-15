//
//  PostTableViewCell.swift
//  VolantDesDomes
//
//  Created by Drusy on 24/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftyAttributes

class PostTableViewCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var excerptLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundedView.layer.cornerRadius = 6
        roundedView.layer.masksToBounds = true
        
        shadowView.backgroundColor = .clear
        if #available(iOS 13.0, *) {
            shadowView.layer.shadowColor = UIColor.label.cgColor
        } else {
            shadowView.layer.shadowColor = UIColor.black.cgColor
        }
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowView.layer.shadowOpacity = 0.15
        shadowView.layer.shadowRadius = 3
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        postImageView.kf.cancelDownloadTask()
        shadowView.transform = .identity
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: -

    func configure(with post: WPPost) {
        titleLabel.text = post.titleHtmlStripped
        excerptLabel.text = post.excerptHtmlStripped
        
        if let authorName = post.author?.name {
            let pointSize = authorLabel.font.pointSize
            let boldFont = UIFont.boldSystemFont(ofSize: pointSize)
            
            authorLabel.isHidden = false
            
            if let date = post.date {
                let dateFormatter = DateFormatter(withFormat: "MM/dd/yyyy' à 'HH:mm", locale: Locale.current.identifier)
                authorLabel.attributedText = "Par ".attributedString
                    + "\(authorName)".withFont(boldFont)
                    + " le ".attributedString
                    + "\(dateFormatter.string(from: date))".withFont(boldFont)
            } else {
                authorLabel.attributedText = "Par ".attributedString
                    + "\(authorName)".withFont(boldFont)
            }
        } else {
            authorLabel.isHidden = true
        }
        
        if let featuredMediaLink = post.featuredMedia?.large, let url = URL(string: featuredMediaLink) {
            postImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        } else if let slug = post.slug, let slugImage = UIImage(named: slug) {
            postImageView.image = slugImage
        } else {
            postImageView.image = #imageLiteral(resourceName: "placeholder")
        }
    }
}
