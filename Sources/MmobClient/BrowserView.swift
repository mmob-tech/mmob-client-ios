import SwiftUI
import WebKit

public class BrowserView: UIViewController, WKNavigationDelegate {

    let helper = MmobClientHelper()
    @IBOutlet weak var webView: WKWebView!

    @IBOutlet weak var buttonBack: UIImageView!
    @IBOutlet weak var buttonForward: UIImageView!
    @IBOutlet weak var buttonClose: UIImageView!

    @IBOutlet weak var textDomain: UILabel!
    @IBOutlet weak var textURL: UILabel!

    let enabledColour = UIColor.systemBlue
    let disabledColour = UIColor.gray

    public override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        updateState()

        webView.layer.borderWidth = 1
        webView.layer.borderColor = UIColor(red: 0.886, green: 0.914, blue: 0.933, alpha: 1).cgColor
    }

    public override func viewWillAppear(_ animated: Bool) {
        buttonBack.tag = 1
        buttonForward.tag = 2
        buttonClose.tag = 3

        buttonBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        buttonForward.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        buttonClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        buttonClose.isUserInteractionEnabled = true
        buttonClose.tintColor = enabledColour
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {

        if sender.view!.tag == buttonBack.tag && webView.canGoBack {
            webView.goBack()
        }
        if sender.view!.tag == buttonForward.tag && webView.canGoForward {
            webView.goForward()
        }
        updateState()
        if sender.view!.tag == buttonClose.tag {
            self.dismiss(animated: true, completion: nil)

        }
    }
    
    func updateState() {
        if webView.canGoBack == false {
            buttonBack.tintColor = disabledColour
            buttonBack.isUserInteractionEnabled = false
        } else {
            buttonBack.tintColor = enabledColour
            buttonBack.isUserInteractionEnabled = true
        }

        if webView.canGoForward == false {
            buttonForward.tintColor = disabledColour
            buttonForward.isUserInteractionEnabled = false
        } else {
            buttonForward.tintColor = enabledColour
            buttonForward.isUserInteractionEnabled = true
        }

        if (webView.url?.absoluteString == "about:blank") {
            textDomain.text = "New page"
            textURL.text = ""
        } else if (webView.url != nil) {
            textDomain.text = webView.title!.isEmpty ? "Loading" : webView.title
            updateURL(url: webView.url!.absoluteString)

        }
    }
    
    func updateURL(url: String) {
        let imageAttachment = NSTextAttachment()
        let isSecure = url.hasPrefix("https://")
        let completeText = NSMutableAttributedString(string: "")
        
        if isSecure == true {
            let image = UIImage(named: "lockFill", in: Bundle.module, compatibleWith:nil)
            
            imageAttachment.image = image
            
            let imageOffsetY: CGFloat = 0.0
            let imageOffsetX: CGFloat = 0.0
            imageAttachment.bounds = CGRect(x: imageOffsetX, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
            let attachmentString = NSAttributedString(attachment: imageAttachment)
            completeText.append(attachmentString)
        }
        let textAfterIcon = NSAttributedString(string: " " + helper.getHost(from: url)!)
        completeText.append(textAfterIcon)
        textURL.attributedText = completeText
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
