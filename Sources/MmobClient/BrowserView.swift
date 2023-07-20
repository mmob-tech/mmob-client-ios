import SwiftUI
import WebKit

public class BrowserView: UIViewController, WKNavigationDelegate {
    let helper = MmobClientHelper()

    @IBOutlet var webView: WKWebView!
    @IBOutlet var webViewTitle: UILabel!
    @IBOutlet var webViewSubTitle: UILabel!
    @IBOutlet var buttonClose: UIImageView!
    @IBOutlet var buttonBack: UIImageView!
    @IBOutlet var buttonForward: UIImageView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        webView.layer.borderWidth = 1
        webView.layer.borderColor = UIColor(named: "Grey2")?.cgColor
        webViewSubTitle.textColor = UIColor(named: "Grey5")
        buttonClose.tintColor = UIColor(named: "Grey5")

        updateState()
    }

    override public func viewWillAppear(_ animated: Bool) {
        buttonBack.tag = 1
        buttonForward.tag = 2
        buttonClose.tag = 3

        buttonBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        buttonForward.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        buttonClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        buttonClose.isUserInteractionEnabled = true
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.view!.tag == buttonBack.tag && webView.canGoBack {
            webView.goBack()
        }

        if sender.view!.tag == buttonForward.tag && webView.canGoForward {
            webView.goForward()
        }

        if sender.view!.tag == buttonClose.tag {
            if let parentViewController = parent {
                willMove(toParent: nil)
                view.removeFromSuperview()
                removeFromParent()
                parentViewController.view.setNeedsLayout()
            }
        }

        updateState()
    }

    private func updateState() {
        if let absoluteString = webView.url?.absoluteString, !absoluteString.isEmpty,
           let title = webView.title, !title.isEmpty
        {
            helper.setWebViewTitle(webViewTitle: webViewTitle, title: title, url: absoluteString)
            webViewSubTitle.text = helper.getHost(from: absoluteString)
        } else {
            helper.setDefaultWebViewValues(title: webViewTitle, subtitle: webViewSubTitle)
        }

        if webView.canGoBack == false {
            buttonBack.isUserInteractionEnabled = false
            buttonBack.tintColor = UIColor(named: "Grey4")
        } else {
            buttonBack.isUserInteractionEnabled = true
            buttonBack.tintColor = UIColor(named: "Grey5")
        }

        if webView.canGoForward == false {
            buttonForward.isUserInteractionEnabled = false
            buttonForward.tintColor = UIColor(named: "Grey4")
        } else {
            buttonForward.isUserInteractionEnabled = true
            buttonForward.tintColor = UIColor(named: "Grey5")
        }
    }

    public func loadURL(url: URL) {
        webView.load(URLRequest(url: url))
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateState()
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateState()
    }

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        updateState()
    }
}
