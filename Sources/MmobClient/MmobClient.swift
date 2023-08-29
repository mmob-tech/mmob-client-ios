import WebKit

public typealias MmobClientView = WKWebView

public class MmobClient: UIViewController, WKNavigationDelegate, WKUIDelegate, UIGestureRecognizerDelegate {
    let helper = MmobClientHelper()
    // TODO: Call client with instanceDomain, will be a breaking change for a future date
    var instanceDomain: InstanceDomain = .MMOB
    var webView = WKWebView()

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

    public func loadIntegrationEntryPoint(mmobConfiguration: MmobIntegration, instanceDomain: InstanceDomain) -> MmobClientView {
        let configuration = mmobConfiguration.configuration
        let customer = mmobConfiguration.customer
        let parameters = self.helper.getIntegrationParameters(
            configuration: configuration,
            customer: customer
        )
        let url = self.helper.getUrl(environment: configuration.environment, instanceDomain: instanceDomain, suffix: "entry_point/cp_DhskfrQ5V0HLfcVwbl54Q/deployment/cpd_wAXWMCu8uI4ceSkU_225H")
        let request = self.helper.getRequest(url: url, parameters: parameters)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTap))

        tapGesture.delegate = self

        self.instanceDomain = instanceDomain
        self.webView.addGestureRecognizer(tapGesture)
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.webView.load(request)
        return self.webView
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func viewTap() -> MmobClientView {
        let testConfiguration = MmobIntegration(
            configuration: MmobIntegrationConfiguration(
                cp_id: "cp_TMaiVSyyzBx2rZqF-PqdY",
                integration_id: "cpd_xH1KQOhFh_hIIVKTCBJF5",
                environment: "stag"
            ),
            customer: MmobCustomerInfo(
            )
        )
        let testInstanceDomain: InstanceDomain = .EFNETWORK
        print("Tapped screen!")
        return self.loadIntegration(mmobConfiguration: testConfiguration, instanceDomain: testInstanceDomain)
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
            self.requestInMmobBrowser(url: navigationAction.request.url!)
        }
        return nil
    }

    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void
    ) {
        let url = navigationAction.request.url!
        let instanceDomainString = self.helper.getInstanceDomain(instanceDomain: self.instanceDomain)
        let domain = self.helper.getRootDomain(from: url)
        let isAffiliateRedirect = self.helper.containsAffiliateRedirect(in: url.absoluteString)
        let isDev = self.helper.isLocalhostURL(url: url)

        // If running locally, load in iframe
        if isDev {
            return decisionHandler(.allow)
        }

        // If domain is mmob and isn't an affiliate, load in iframe
        if domain == instanceDomainString && !isAffiliateRedirect {
            return decisionHandler(.allow)
        }

        // Load in MMOB In app browser
        self.requestInMmobBrowser(url: url)
        return decisionHandler(.cancel)
    }

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
