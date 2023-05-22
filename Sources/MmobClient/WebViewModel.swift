//
//  WebViewModel.swift
//
//
//  Created by Hasseeb Hussain on 22/05/2023.
//

import SwiftUI
import WebKit 

class WebViewModel: ObservableObject {
    @Published var webView: WKWebView = .init()
    @Published var title = ""
    @Published var url = ""
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    
    
}
