//
//  WebViewModel.swift
//  mmob-tester
//
//  Created by Hasseeb Hussain on 11/05/2023.
//

import Foundation
import WebKit

class WebViewModel: ObservableObject {
    @Published var webView: WKWebView = .init()
    @Published var title: String = ""
    @Published var url: String = ""
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    func goBack() {
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }
}
