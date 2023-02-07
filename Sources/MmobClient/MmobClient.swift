
import SwiftUI
import WebKit


public typealias MmobClientView = WKWebView

public struct MmobCustomerInfo {
    public init(email: String? = nil, first_name: String? = nil, surname: String? = nil, gender: String? = nil, title: String? = nil, building_number: String? = nil, address_1: String? = nil, town_city: String? = nil, postcode: String? = nil, dob: String? = nil) {
        self.email = email
        self.first_name = first_name
        self.surname = surname
        self.gender = gender
        self.title = title
        self.building_number = building_number
        self.address_1 = address_1
        self.town_city = town_city
        self.postcode = postcode
        self.dob = dob
    }
    
    var email: String?
    var first_name: String?
    var surname: String?
    var gender: String?
    var title: String?
    var building_number: String?
    var address_1: String?
    var town_city: String?
    var postcode: String?
    var dob: String?
}

public struct MmobCompanyConfiguration {
    public init(cp_id: String, integration_id: String, environment: String = "production") {
        self.cp_id = cp_id
        self.integration_id = integration_id
        self.environment = environment
    }
    
    var cp_id: String
    var integration_id: String
    var environment: String
}


public struct MmobDistributionConfiguration {
    public init(distribution_id: String, environment: String = "production") {
        self.distribution_id = distribution_id
        self.environment = environment
    }
    
    var distribution_id: String
    
    var environment: String
}

public struct MmobDistribution {
    public init(configuration: MmobDistributionConfiguration, customer: MmobCustomerInfo) {
        self.configuration = configuration
        self.customer = customer
    }
    
    var configuration: MmobDistributionConfiguration
    var customer: MmobCustomerInfo
}

public struct MmobConfiguration {
    public init(configuration: MmobCompanyConfiguration, customer: MmobCustomerInfo) {
        self.configuration = configuration
        self.customer = customer
    }
    
    
    var configuration: MmobCompanyConfiguration
    var customer: MmobCustomerInfo
}

typealias MmobParameters = [String: String?];

public class MmobClient : UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    public var webView:WKWebView = WKWebView()
    public let version = "0.3.0"
    
    var urlPrefix: String = ""

    
    func getBundlerId() -> String {
        let bundleID = Bundle.main.bundleIdentifier!
        return bundleID
    }
    
    func getUrl(environment: String, instanceDomain: String) {
        // Set client url entry point
        let local_url =  "http://localhost:3100/"
        let dev_url =  "https://client-ingress.dev." + instanceDomain
        let stag_url = "https://client-ingress.stag." + instanceDomain
        let prod_url = "https://client-ingress.prod." + instanceDomain
        
        switch environment {
        case "local":
            self.urlPrefix = local_url
            break
        case "dev":
            self.urlPrefix = dev_url
            break
        case "stag":
            self.urlPrefix = stag_url
            break
            
        default:
            self.urlPrefix = prod_url
        }
    }
    
    
    func getParameters(customer: MmobCustomerInfo) -> MmobParameters {
        let parameters: MmobParameters = [
            "email": customer.email,
            "first_name": customer.first_name,
            "surname": customer.surname,
            "title": customer.title,
            "building_number": customer.building_number,
            "address_1": customer.address_1,
            "town_city": customer.town_city,
            "postcode": customer.postcode,
            
        ]
        return parameters
    }
    
    public  func getDistribution(mmobDistribution: MmobDistribution, instanceDomain: String ) -> MmobClientView {
        let view =  WKWebView()
        let configuration = mmobDistribution.configuration
        let customer = mmobDistribution.customer
        
        getUrl(environment: configuration.environment, instanceDomain: instanceDomain)
        let url = URL(string:self.urlPrefix + "/tpp/distribution/boot")!
        
        let parameters = getParameters(customer: customer)
        
        
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let bootRequestConfiguration = [
            "distribution_id": configuration.distribution_id,
            "identifier_type": "ios",
            "identifier_value": getBundlerId()
        ]
        
        let bootRequest = [
            "configuration": bootRequestConfiguration,
            "customer_info": parameters
        ]
        
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bootRequest, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        view.load(request)
        return view
    }
    
    public func getClient(mmobConfiguration: MmobConfiguration, instanceDomain: String) -> MmobClientView   {
        
        let customer = mmobConfiguration.customer
        let company = mmobConfiguration.configuration
        
        let parameters: [String: String?] = [
            "email": customer.email,
            "first_name": customer.first_name,
            "surname": customer.surname,
            "title": customer.title,
            "building_number": customer.building_number,
            "address_1": customer.address_1,
            "town_city": customer.town_city,
            "postcode": customer.postcode,
            "cp_id": company.cp_id,
            "cp_deployment_id": company.integration_id
        ]
        
        
        getUrl(environment: company.environment, instanceDomain: instanceDomain)
        let url = URL(string: self.urlPrefix + "/boot")!
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self

        self.webView.load(request)
        return self.webView
    }
    
    // Handle window.open in the same webView
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    
    // Open non instance domains in safari rather than the webview
    // WARNING: Cookies are not shared, so the session will be empty on Safari
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {

        let url = navigationAction.request.url!
        
        if ((url.relativeString.hasPrefix(self.urlPrefix)) == true) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
            UIApplication.shared.canOpenURL(url)
            UIApplication.shared.open(url)
        }
    }
    
}

