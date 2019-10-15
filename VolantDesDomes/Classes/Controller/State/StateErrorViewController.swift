//
//  StateErrorViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 27/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit

class StateErrorViewController: AbstractViewController {

    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var errorSubtitleLabel: UILabel!
    
    var titleString: String
    var subtitleString: String
    var touchHandler: (() -> Void)?
    
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onViewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: -
    
    @objc func onViewTapped() {
        touchHandler?()
    }
    
    override func update() {
        super.update()
        
        errorTitleLabel.text = titleString
        errorSubtitleLabel.text = subtitleString
    }
}
