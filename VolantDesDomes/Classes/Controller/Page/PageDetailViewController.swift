//
//  PageDetailViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 31/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import WebKit

class PageDetailViewController: AbstractViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            webView.configuration.preferences.javaScriptEnabled = true
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.scrollView.delegate = self
        }
    }
    
    lazy var shareBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .action,
                               target: self,
                               action: #selector(onShareTouched))
    }()
    
    var url: URL
    var navigationTitle: String?
    
    init(title: String?, url: URL) {
        self.navigationTitle = title
        self.url = url
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = navigationTitle
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItems = [shareBarButtonItem]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        webView.stopLoading()
    }
    
    // MARK: -
    
    override func update() {
        super.update()
        
        webView.load(URLRequest(url: url))
    }
    
    // MARK: - Actions
    
    @objc func onShareTouched() {
        let activityViewController = share(link: url.absoluteString)
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - WKWebViewDelegate

extension PageDetailViewController: WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activityIndicator.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
        activityIndicator.isHidden = true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == .linkActivated {
            if let requestURL = navigationAction.request.url {
                showSafariViewController(for: requestURL.absoluteString)
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.navigationType == .linkActivated {
            if let requestURL = navigationAction.request.url {
                showSafariViewController(for: requestURL.absoluteString)
            }
        }
        
        return nil
    }
}
