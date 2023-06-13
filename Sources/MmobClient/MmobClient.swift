import SwiftUI
import WebKit

public typealias MmobClientView = WKWebView

public class MmobClient: UIViewController, WKNavigationDelegate, WKUIDelegate {
    let version = "0.4.0"
    let helper = MmobClientHelper()
    var instanceURL: String!
    var webView = WKWebView()

    public func loadIntegration(mmobConfiguration: MmobIntegration, instanceDomain: InstanceDomain = InstanceDomain.MMOB) -> MmobClientView {
        let customer = mmobConfiguration.customer
        let company = mmobConfiguration.configuration
        let parameters = self.helper.getIntegrationParameters(
            company: mmobConfiguration.configuration,
            customer: customer
        )
        let instanceDomainString = self.helper.getInstanceDomain(
            domain: instanceDomain
        )
        self.instanceURL = self.helper.getBootUrl(environment: company.environment, instanceDomain: instanceDomainString)
        let url = URL(
            string: self.helper.getBootUrl(
                environment: company.environment, instanceDomain: instanceDomainString
            ) + "/boot"
        )!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
        }

        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.webView.load(request)
        return self.webView
    }

    public func loadDistribution(
        mmobConfiguration: MmobDistribution,
        instanceDomain: InstanceDomain
    ) -> MmobClientView {
        let configuration = mmobConfiguration.configuration
        let customer = mmobConfiguration.customer
        let parameters = self.helper.getDistributionParameters(customer: customer)
        let instanceDomainString = self.helper.getInstanceDomain(domain: instanceDomain)
        let url = URL(string: helper.getBootUrl(
            environment: configuration.environment,
            instanceDomain: instanceDomainString
        ) + "/tpp/distribution/boot")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let bootRequestConfiguration = [
            "distribution_id": configuration.distribution_id,
            "identifier_type": "ios",
            "identifier_value": self.helper.getBundleID()
        ]

        let bootRequest = [
            "configuration": bootRequestConfiguration,
            "customer_info": parameters
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bootRequest, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
        }

        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.webView.load(request)
        return self.webView
    }

    // Handle window.open in the same webView
    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        } else {
            self.loadExternalURL(url: navigationAction.request.url!)
        }
        return nil
    }

    // Open non instance domains in safari rather than the webview
    // WARNING: Cookies are not shared, so the session will be empty on Safari
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void
    ) {
        let url = navigationAction.request.url!
        let urlString = url.absoluteString
        let isInstanceDomain = urlString.hasPrefix(self.instanceURL)
        let isAffiliateRedirect = self.helper.containsAffiliateRedirect(in: urlString)

        if isInstanceDomain == true && isAffiliateRedirect == false {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
            self.loadExternalURL(url: url)
        }
    }

    func loadExternalURL(url: URL) {
        let topVC = self.topMostController()
        let storyboard = UIStoryboard(name: "BrowserView", bundle: Bundle.module)
        let browserView = storyboard.instantiateViewController(withIdentifier: "BrowserViewBoard") as! BrowserView
        browserView.modalPresentationStyle = .fullScreen
        topVC.present(browserView, animated: true)
        browserView.loadURL(url: url)
    }

    // https://stackoverflow.com/a/58622251
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while topController.presentedViewController != nil {
            topController = topController.presentedViewController!
        }
        return topController
    }
}
