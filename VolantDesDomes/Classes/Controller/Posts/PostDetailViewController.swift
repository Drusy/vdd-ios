//
//  PostDetailViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 24/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import WebKit

class PostDetailViewController: AbstractViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            webView.configuration.preferences.javaScriptEnabled = true
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.scrollView.delegate = self
        }
    }
    
    var post: WPPost
    var currentPost: WPPost
    
    lazy var shareBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .action,
                               target: self,
                               action: #selector(onShareTouched))
    }()
    lazy var favoriteBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: post.favorite ? #imageLiteral(resourceName: "nav-favorite-on") : #imageLiteral(resourceName: "nav-favorite-off"),
                               style: .plain,
                               target: self,
                               action: #selector(onFavoriteTouched))
    }()
    
    init(post: WPPost) {
        self.post = post
        self.currentPost = post
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItems = [shareBarButtonItem, favoriteBarButtonItem]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        webView.stopLoading()
    }
    
    // MARK: -
    
    override func themeUpdated() {
        super.themeUpdated()
        
        view.backgroundColor = StyleManager.shared.backgroundColor
        activityIndicator.color = StyleManager.shared.textColor
    }
    
    override func update() {
        super.update()
        
        load(post: post)
    }
    
    func load(post: WPPost) {
        currentPost = post
        
        webView.loadHTMLString(
            loadTemplate(),
            baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }
    
    func loadTemplate() -> String {
        let hasMedia = post.featuredMedia?.large != nil
        var contentRendered = currentPost.content?.rendered ?? ""
        contentRendered = contentRendered.replacingOccurrences(of: "file://", with: "http://")
        contentRendered = contentRendered.replacingOccurrences(of: "\"//", with: "\"https://")
        contentRendered = contentRendered.replacingOccurrences(of: "href=\"/", with: "href=\"\(ApiRequest.hostURL)/")

        guard let url = Bundle.main.url(forResource: hasMedia ? "template_image" : "template_gradient", withExtension: "html") else { return contentRendered }
        guard var template = try? String(contentsOf: url) else { return contentRendered }
        let dateFormatter = DateFormatter(withFormat: "'le' MM/dd/yyyy' à 'HH:mm", locale: Locale.current.identifier)
        
        template = template.replacingOccurrences(of: "{{ title }}", with: post.title?.rendered ?? "")
        template = template.replacingOccurrences(of: "{{ content }}", with: contentRendered)
        template = template.replacingOccurrences(of: "{{ user }}", with: post.author?.name ?? "Webmaster")

        if let pictureURL = post.featuredMedia?.large {
            template = template.replacingOccurrences(of: "{{ pictureURL }}", with: pictureURL)
        } else {
            template = template.replacingOccurrences(of: "{{ pictureURL }}", with: "")
        }

        if let categories = post.categories {
            template = template.replacingOccurrences(
                of: "{{ categories }}",
                with: categories
                    .compactMap { $0.name }
                    .map { "<span class=\"label label-primary\"><a>\($0)</a></span>" }
                    .joined(separator: " "))
        } else {
            template = template.replacingOccurrences(of: "{{ categories }}", with: "")
        }
        
        if let date = post.date {
            template = template.replacingOccurrences(of: "{{ date }}", with: dateFormatter.string(from: date))
        } else {
            template = template.replacingOccurrences(of: "{{ date }}", with: "")
        }

        return template
    }
    
    // MARK: - Actions
    
    @objc func onShareTouched() {
        let activityViewController = share(title: post.titleHtmlStripped,
                                           content: post.excerptHtmlStripped,
                                           link: post.link,
                                           image: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func onFavoriteTouched() {
        try? realm.write {
            post.favorite = !post.favorite
        }
        favoriteBarButtonItem.image = post.favorite ? #imageLiteral(resourceName: "nav-favorite-on") : #imageLiteral(resourceName: "nav-favorite-off")
    }
}

// MARK: - WKWebViewDelegate

extension PostDetailViewController: WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {
    
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
