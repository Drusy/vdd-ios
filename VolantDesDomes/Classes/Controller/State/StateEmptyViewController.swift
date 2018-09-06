//
//  StateEmptyViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 29/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit

class StateEmptyViewController: AbstractViewController {

    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptySubtitleLabel: UILabel!
    
    var titleString: String
    var subtitleString: String
    var titleColor: UIColor
    var subtitleColor: UIColor
    var backgroundColor: UIColor
    
    init(title: String, subtitle: String, titleColor: UIColor = .black, subtitleColor: UIColor = .darkGray, backgroundColor: UIColor = .white) {
        self.titleString = title
        self.subtitleString = subtitle
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.backgroundColor = backgroundColor
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: -
    
    override func update() {
        super.update()
        
        emptyTitleLabel.text = titleString
        emptySubtitleLabel.text = subtitleString
        emptyTitleLabel.textColor = titleColor
        emptySubtitleLabel.textColor = subtitleColor
        view.backgroundColor = backgroundColor
    }
}
