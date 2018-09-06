//
//  StateLoadingViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 27/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit

class StateLoadingViewController: AbstractViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var string: String
    var tintColor: UIColor
    var backgroundColor: UIColor
    
    init(string: String, tintColor: UIColor = .black, backgroundColor: UIColor = .white) {
        self.string = string
        self.tintColor = tintColor
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
        
        loadingLabel.textColor = tintColor
        activityIndicator.color = tintColor
        loadingLabel.text = string
        view.backgroundColor = backgroundColor
    }
}
