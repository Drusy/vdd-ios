//
//  PageCollectionViewCell.swift
//  VolantDesDomes
//
//  Created by Drusy on 31/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RxSwift

class PageCollectionViewCell: UICollectionViewCell, CellIdentifiable {

    @IBOutlet weak var pageImageView: UIImageView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var roundedView: UIView!
    
    let disposeBag = DisposeBag()

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
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        shadowView.backgroundColor = .clear
        
        roundedView.layer.cornerRadius = 4
        roundedView.layer.masksToBounds = true
        
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
        
        pageImageView.kf.cancelDownloadTask()
        shadowView.transform = .identity
    }
    
    // MARK: -
    
    func themeUpdated() {
        pageTitleLabel.textColor = StyleManager.shared.textColor
        roundedView.backgroundColor = StyleManager.shared.backgroundContentColor
    }
    
    func configure(with page: PageItem) {
        pageTitleLabel.text = page.title
        pageImageView.image = page.image
    }
}
