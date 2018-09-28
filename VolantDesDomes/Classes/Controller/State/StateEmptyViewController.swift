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
    
    init(title: String, subtitle: String) {
        self.titleString = title
        self.subtitleString = subtitle
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: -
    
    override func themeUpdated() {
        super.themeUpdated()
        
        emptyTitleLabel.textColor = StyleManager.shared.textColor
        emptySubtitleLabel.textColor = StyleManager.shared.subtitleColor
        view.backgroundColor = StyleManager.shared.backgroundColor
    }
    
    override func update() {
        super.update()
        
        emptyTitleLabel.text = titleString
        emptySubtitleLabel.text = subtitleString
    }
}
