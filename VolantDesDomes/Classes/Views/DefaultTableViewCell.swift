//
//  DefaultTableViewCell.swift
//  VolantDesDomes
//
//  Created by Drusy on 31/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RxSwift

class DefaultTableViewCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var defaultTitleLabel: UILabel!
    @IBOutlet weak var defaultSubtitleLabel: UILabel!
    
    let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.rx
            .notification(Notification.Name.themeUpdated)
            .startWith(Notification(name: .themeUpdated))
            .subscribe(onNext: { [weak self] notification in
                self?.themeUpdated()
            })
            .disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: -
    
    func themeUpdated() {
        defaultTitleLabel.textColor = StyleManager.shared.textColor
        defaultSubtitleLabel.textColor = StyleManager.shared.subtitleColor
        
        contentView.backgroundColor = StyleManager.shared.backgroundContentColor
        backgroundColor = StyleManager.shared.backgroundContentColor
    }
    
    func configure(title: String?, subtitle: String?) {
        defaultTitleLabel.isHidden = title == nil
        defaultTitleLabel.text = title
        defaultSubtitleLabel.isHidden = subtitle == nil
        defaultSubtitleLabel.text = subtitle
    }
}
