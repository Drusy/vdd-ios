//
//  AboutViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 05/09/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import ActiveLabel
import SafariServices

class AboutViewController: AbstractViewController {

    @IBOutlet weak var activeDescriptionLabel: ActiveLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "À propos"
        
        setupActiveLabel()
    }
    
    // MARK: -
    
    override func enableDarkMode() {
        setupActiveLabel()
    }
    
    override func disableDarkMode() {
        setupActiveLabel()
    }
    
    
    func setupActiveLabel() {
        activeDescriptionLabel.customize { label in
            label.enabledTypes = [.url, .mention]
            
            // Mention
            label.mentionColor = StyleManager.shared.tintColor
            label.handleMentionTap{ [weak self] mention in
                var url: URL?
                
                if mention.contains("Openium") {
                    url = URL(string : "https://openium.fr")
                } else if mention.contains("Drusy") {
                    url = URL(string : "https://github.com/Drusy")
                } else if mention.contains("FlatIcons") {
                    url = URL(string : "http://www.flaticon.com")
                } else if mention.contains("Freepik") {
                    url = URL(string : "http://www.freepik.com")
                } else if mention.contains("PopcornsArts") {
                    url = URL(string : "http://www.flaticon.com/authors/popcorns-arts")
                }
                
                if let url = url {
                    let svc = SFSafariViewController(url: url)
                    self?.present(svc, animated: true, completion: nil)
                }
            }
            
            // Urls
            label.URLColor = StyleManager.shared.tintColor
            label.handleURLTap { [weak self] url in
                let svc = SFSafariViewController(url: url)
                self?.present(svc, animated: true, completion: nil)
            }
        }
    }
}
