import WebKit


public typealias MmobClientView = WKWebView


public class MmobClient: UIViewController, WKNavigationDelegate, WKUIDelegate {
    let helper = MmobClientHelper()
    // TODO: Call client with instanceDomain, will be a breaking change for a future date
    var instanceDomain: InstanceDomain = .MMOB
    var webView = WKWebView()

    @objc
    public func loadDistribution(
        mmobConfiguration: MmobDistribution,
        instanceDomain: InstanceDomain
    ) -> MmobClientView {
        let configuration = mmobConfiguration.configuration
        let customer = mmobConfiguration.customer
        let parameters = self.helper.getDistributionParameters(
            configuration: configuration,
            customer: customer
        )
        let url = self.helper.getUrl(environment: configuration.environment, instanceDomain: self.instanceDomain, suffix: "tpp/distribution/boot")
        let request = self.helper.getRequest(url: url, parameters: parameters)

        self.instanceDomain = instanceDomain
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.webView.load(request)
        return self.webView
    }
    
    @objc
    public func loadIntegration(mmobConfiguration: MmobIntegration, instanceDomain: InstanceDomain) -> MmobClientView {
        let configuration = mmobConfiguration.configuration
        let customer = mmobConfiguration.customer
        let parameters = self.helper.getIntegrationParameters(
            configuration: configuration,
            customer: customer
        )
        let url = self.helper.getUrl(environment: configuration.environment, instanceDomain: instanceDomain, suffix: "boot")
        let request = self.helper.getRequest(url: url, parameters: parameters)

        self.instanceDomain = instanceDomain
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.webView.load(request)
        return self.webView
    }


    // Handle window.open in the same webView
    @objc
    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        } else {
            self.requestInMmobBrowser(url: navigationAction.request.url!)
        }
        return nil
    }

    // Gives us a chance to take control when a URL is about to be loaded in the MmobView
    // decisionHandler(.cancel) to cancel current load
    @objc
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void
    ) {
        let url = navigationAction.request.url!

        // url is invalid, cancel current load
        let isValidUrl = self.helper.isValidURL(url: url)
        if !isValidUrl {
            return decisionHandler(.cancel)
        }

        // url does not begin with http / https, open in native browser, cancel current load
        let isValidUrlScheme = self.helper.isValidUrlScheme(url: url)
        if !isValidUrlScheme {
            UIApplication.shared.open(url)
            return decisionHandler(.cancel)
        }

        // url domain is blacklisted, open in native browser, cancel current load
        let isBlacklistedDomain = self.helper.isBlacklistedDomain(url: url)
        if isBlacklistedDomain {
            UIApplication.shared.open(url)
            return decisionHandler(.cancel)
        }

        // Instance domain matches, is not an affiliate redirect, continue within current view
        let domain = self.helper.getRootDomain(from: url)
        let instanceDomainString = self.helper.getInstanceDomain(instanceDomain: self.instanceDomain)

        let isAffiliateRedirect = self.helper.containsAffiliateRedirect(in: url.absoluteString)
        let isLocal = self.helper.containsLocalLink(in: url.absoluteString)

        if domain == instanceDomainString && !isAffiliateRedirect {
            return decisionHandler(.allow)
        }

        if isLocal {
            return decisionHandler(.allow)
        }

        // Otherwise, launch URL in MmobBrowser
        self.requestInMmobBrowser(url: url)
        return decisionHandler(.cancel)
    }
    
    @objc
    func requestInMmobBrowser(url: URL) {
        let topVC = self.helper.getTopMostController()
        let storyboard = UIStoryboard(name: "BrowserView", bundle: Bundle.module)
        let initialViewController = storyboard.instantiateInitialViewController()
        let browserView = initialViewController as! BrowserView

        if let initialViewController = initialViewController {
            // TODO: Add an animated transition
            topVC.view.addSubview(initialViewController.view)
            initialViewController.view.frame = view.bounds
            topVC.addChild(initialViewController)
            initialViewController.didMove(toParent: self)

            browserView.loadURL(url: url)
        }
    }
}
