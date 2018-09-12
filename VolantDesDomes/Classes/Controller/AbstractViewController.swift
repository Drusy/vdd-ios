//
//  AbtractViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 24/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import SafariServices

class AbstractViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        update()
    }
    
    // MARK: -
    
    func update() {
    
    }
    
    func showSafariViewController(for urlString: String?) {
        guard let urlString = urlString else { return }
        guard let url = URL(string: urlString) else { return }
        
        if url.scheme == "https" || url.scheme == "http" {
            present(SFSafariViewController(url: url),
                    animated: true,
                    completion: nil)
        } else if UIApplication.shared.canOpenURL(url) {   
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func share(title: String? = nil, content: String? = nil, link: String? = nil, image: UIImage? = nil, fromView view: UIView? = nil) -> UIActivityViewController {
        var items = [Any]()
        
        if let content = content {
            items.append(content as Any)
        }
        
        if let image = image {
            items.append(image)
        }
        
        if let content = link {
            if let url = URL(string: content) {
                items.append(url as Any)
            }
        }
        
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let view = view {
            activityController.popoverPresentationController?.sourceView = view
            activityController.popoverPresentationController?.sourceRect = view.bounds
        }
        
        if let title = title {
            activityController.setValue(title, forKey: "subject")
        }
        
        return activityController
    }
}
