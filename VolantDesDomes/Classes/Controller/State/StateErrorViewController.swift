//
//  StateErrorViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 27/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RxGesture

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
        
        view.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.touchHandler?()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: -
    
    override func themeUpdated() {
        super.themeUpdated()
        
        errorTitleLabel.textColor = StyleManager.shared.textColor
        errorSubtitleLabel.textColor = StyleManager.shared.subtitleColor
        view.backgroundColor = StyleManager.shared.backgroundColor
    }
    
    override func update() {
        super.update()
        
        errorTitleLabel.text = titleString
        errorSubtitleLabel.text = subtitleString
    }
}
