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
import RxSwift

class PostTableViewCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var excerptLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        roundedView.layer.cornerRadius = 6
        roundedView.layer.masksToBounds = true
        
        shadowView.backgroundColor = .clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowView.layer.shadowOpacity = 0.15
        shadowView.layer.shadowRadius = 3
        
        NotificationCenter.default.rx
            .notification(Notification.Name.themeUpdated)
            .startWith(Notification(name: .themeUpdated))
            .subscribe(onNext: { [weak self] notification in
                self?.themeUpdated()
            })
            .disposed(by: disposeBag)
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
    
    func themeUpdated() {
        titleLabel.textColor = StyleManager.shared.textColor
        excerptLabel.textColor = StyleManager.shared.subtitleColor
        authorLabel.textColor = StyleManager.shared.textColor
        roundedView.backgroundColor = StyleManager.shared.backgroundContentColor
    }

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
