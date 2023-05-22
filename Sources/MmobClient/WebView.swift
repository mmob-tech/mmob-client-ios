//
//  WebView.swift
//
//
//  Created by Hasseeb Hussain on 16/05/2023.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let instanceDomain: String

    @ObservedObject var model: WebViewModel
    @Binding var request: URLRequest
    @Binding var isNotInstanceDomain: Bool

    init(instanceDomain: String, model: WebViewModel, request: Binding<URLRequest>, isNotInstanceDomain: Binding<Bool>) {
        self.instanceDomain = instanceDomain
        self.model = model
        self._request = request
        self._isNotInstanceDomain = isNotInstanceDomain
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()

        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.load(request)

        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(instanceDomain: instanceDomain, model: model, request: $request, isNotInstanceDomain: $isNotInstanceDomain)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let helper = MmobClientHelper()
        let instanceDomain: String

        @ObservedObject var model: WebViewModel
        @Binding var request: URLRequest
        @Binding var isNotInstanceDomain: Bool

        init(instanceDomain: String, model: WebViewModel, request: Binding<URLRequest>, isNotInstanceDomain: Binding<Bool>) {
            self.instanceDomain = instanceDomain
            self.model = model
            self._request = request
            self._isNotInstanceDomain = isNotInstanceDomain
        }

        // WebView finished loading content
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if (isNotInstanceDomain) {
                model.webView = webView
                model.title = webView.title!
                model.url = helper.getHost(from: webView.url!.absoluteString)!
                model.canGoBack = webView.canGoBack
                model.canGoForward = webView.canGoForward
            }
        }

        // Handle navigation requests
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            request = navigationAction.request

            if let rootDomain = helper.getRootDomain(from: request.url!.absoluteString), rootDomain == instanceDomain {
                isNotInstanceDomain = false
                decisionHandler(.allow)
            } else {
                if isNotInstanceDomain {
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)
                }

                isNotInstanceDomain = true
            }
        }

        // Handle 'window.open' calls
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
