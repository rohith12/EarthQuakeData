//
//  DetailsViewController.swift
//  EarthQuakeDetails
//
//  Created by Rohith Raju on 4/10/21.
//  Copyright © 2021 Rohith Raju. All rights reserved.
//

import UIKit
import WebKit

class DetailsViewController: UIViewController {
    var webView: WKWebView!
    var urlString = ""
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        self.view.bringSubviewToFront(self.activityIndicator)
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }
    }
    
    private func setupWebView() {
      let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.frame = self.view.bounds
        self.view.addSubview(webView)
    }
    
    private func showAlertView(message: Error) {
        let alert = UIAlertController(title: "Error", message: message.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

extension DetailsViewController: WKUIDelegate, WKNavigationDelegate {
    
   func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if(error._code == NSURLErrorNotConnectedToInternet){
            showAlertView(message: error)
        }
        self.activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
}


