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
    
    var loadingString: String
    
    init(loadingString: String) {
        self.loadingString = loadingString
        
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
        
        loadingLabel.textColor = StyleManager.shared.textColor
        activityIndicator.color = StyleManager.shared.textColor
        view.backgroundColor = StyleManager.shared.backgroundColor
    }
    
    override func update() {
        super.update()
        
        loadingLabel.text = loadingString
    }
}
