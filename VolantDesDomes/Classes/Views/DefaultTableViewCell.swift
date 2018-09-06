//
//  DefaultTableViewCell.swift
//  VolantDesDomes
//
//  Created by Drusy on 31/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit

class DefaultTableViewCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var defaultTitleLabel: UILabel!
    @IBOutlet weak var defaultSubtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: -
    
    func configure(title: String?, subtitle: String?) {
        defaultTitleLabel.isHidden = title == nil
        defaultTitleLabel.text = title
        defaultSubtitleLabel.isHidden = subtitle == nil
        defaultSubtitleLabel.text = subtitle
    }
}
