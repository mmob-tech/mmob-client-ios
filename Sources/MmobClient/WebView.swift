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
        
        model.webView = webView
        model.webView.navigationDelegate = context.coordinator
        model.webView.uiDelegate = context.coordinator
        model.webView.allowsBackForwardNavigationGestures = true
        model.webView.load(request)

        return model.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(instanceDomain: instanceDomain, model: model, request: $request, isNotInstanceDomain: $isNotInstanceDomain)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
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

        // WebView started loading content
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("WebView started loading content")
        }

        // WebView finished loading content
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView finished loading content")
            model.title = webView.title!
            model.url = webView.url!.absoluteString
            model.canGoBack = webView.canGoBack
            model.canGoForward = webView.canGoForward
        }

        // WebView failed to load content with an error
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView failed to load content with an error")
        }

        // Handle navigation requests
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            request = navigationAction.request

            if let rootDomain = getRootDomain(from: request.url!.absoluteString), rootDomain == instanceDomain {
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

        func getRootDomain(from url: String) -> String? {
            guard let url = Foundation.URL(string: url),
                  let host = url.host
            else {
                return nil
            }

            var components = host.components(separatedBy: ".")

            // Remove subdomains if present
            while components.count > 2 {
                components.removeFirst()
            }

            return components.joined(separator: ".")
        }
    }
}
