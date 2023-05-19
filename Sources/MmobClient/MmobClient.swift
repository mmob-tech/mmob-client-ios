
import SwiftUI
import WebKit

public struct MmobCustomerInfo {
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
}

public struct MmobIntegrationConfiguration {
    var cp_id: String
    var integration_id: String
    var environment: String

    public init(cp_id: String, integration_id: String, environment: String = "production") {
        self.cp_id = cp_id
        self.integration_id = integration_id
        self.environment = environment
    }
}

public struct MmobDistributionConfiguration {
    var distribution_id: String
    var environment: String

    public init(distribution_id: String, environment: String = "production") {
        self.distribution_id = distribution_id
        self.environment = environment
    }
}

public struct MmobIntegration {
    var configuration: MmobIntegrationConfiguration
    var customer: MmobCustomerInfo

    public init(configuration: MmobIntegrationConfiguration, customer: MmobCustomerInfo) {
        self.configuration = configuration
        self.customer = customer
    }
}

public struct MmobDistribution {
    var configuration: MmobDistributionConfiguration
    var customer: MmobCustomerInfo

    public init(configuration: MmobDistributionConfiguration, customer: MmobCustomerInfo) {
        self.configuration = configuration
        self.customer = customer
    }
}

typealias MmobParameters = [String: String?]


public class MmobClient: UIViewController {
    let webView: WKWebView = .init()
    var urlPrefix = ""

    public func loadIntegration(mmobConfiguration: MmobIntegration, instanceDomain: String) -> some View {
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

        self.getUrl(environment: company.environment, instanceDomain: instanceDomain)
        let url = URL(string: self.urlPrefix + "/boot")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
        }
        return MmobView(request: request, instanceDomain: instanceDomain)
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
            "postcode": customer.postcode
        ]
        return parameters
    }

    func getUrl(environment: String, instanceDomain: String) {
        let local_url = "http://localhost:3100/"
        let dev_url = "https://client-ingress.dev." + instanceDomain
        let stag_url = "https://client-ingress.stag." + instanceDomain
        let prod_url = "https://client-ingress.prod." + instanceDomain

        switch environment {
        case "local":
            self.urlPrefix = local_url
        case "dev":
            self.urlPrefix = dev_url
        case "stag":
            self.urlPrefix = stag_url
        default:
            self.urlPrefix = prod_url
        }
    }
}

//
// public class MmobClient: UIViewController, WKNavigationDelegate, WKUIDelegate {
//    public var webView: WKWebView = .init()
//    var urlPrefix: String = ""
//
//    public func loadIntegration(mmobConfiguration: MmobIntegration, instanceDomain: String) -> WKWebView {
//        let customer = mmobConfiguration.customer
//        let company = mmobConfiguration.configuration
//
//        let parameters: [String: String?] = [
//            "email": customer.email,
//            "first_name": customer.first_name,
//            "surname": customer.surname,
//            "title": customer.title,
//            "building_number": customer.building_number,
//            "address_1": customer.address_1,
//            "town_city": customer.town_city,
//            "postcode": customer.postcode,
//            "cp_id": company.cp_id,
//            "cp_deployment_id": company.integration_id
//        ]
//
//        self.getUrl(environment: company.environment, instanceDomain: instanceDomain)
//        let url = URL(string: self.urlPrefix + "/boot")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        self.webView.navigationDelegate = self
//        self.webView.uiDelegate = self
//        self.webView.load(request)
//
//        return self.webView
//    }
//
//    public func loadDistribution(mmobConfiguration: MmobDistribution, instanceDomain: String) -> WKWebView {
//        let configuration = mmobConfiguration.configuration
//        let customer = mmobConfiguration.customer
//        let parameters = self.getParameters(customer: customer)
//
//        self.getUrl(environment: configuration.environment, instanceDomain: instanceDomain)
//        let url = URL(string: self.urlPrefix + "/tpp/distribution/boot")!
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//        let bootRequestConfiguration = [
//            "distribution_id": configuration.distribution_id,
//            "identifier_type": "ios",
//            "identifier_value": self.getBundleID()
//        ]
//
//        let bootRequest = [
//            "configuration": bootRequestConfiguration,
//            "customer_info": parameters
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: bootRequest, options: .prettyPrinted)
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        self.webView.navigationDelegate = self
//        self.webView.uiDelegate = self
//        self.webView.load(request)
//
//        return self.webView
//    }
//
//    func getBundleID() -> String {
//        let bundleID = Bundle.main.bundleIdentifier!
//        return bundleID
//    }
//
//    func getParameters(customer: MmobCustomerInfo) -> MmobParameters {
//        let parameters: MmobParameters = [
//            "email": customer.email,
//            "first_name": customer.first_name,
//            "surname": customer.surname,
//            "title": customer.title,
//            "building_number": customer.building_number,
//            "address_1": customer.address_1,
//            "town_city": customer.town_city,
//            "postcode": customer.postcode
//        ]
//        return parameters
//    }
//
//    func getUrl(environment: String, instanceDomain: String) {
//        let local_url = "http://localhost:3100/"
//        let dev_url = "https://client-ingress.dev." + instanceDomain
//        let stag_url = "https://client-ingress.stag." + instanceDomain
//        let prod_url = "https://client-ingress.prod." + instanceDomain
//
//        switch environment {
//        case "local":
//            self.urlPrefix = local_url
//        case "dev":
//            self.urlPrefix = dev_url
//        case "stag":
//            self.urlPrefix = stag_url
//        default:
//            self.urlPrefix = prod_url
//        }
//    }
//
//    // Delegate methods
//    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        if navigationAction.targetFrame == nil {
//            webView.load(navigationAction.request)
//        }
//        return nil
//    }
//
//    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
//        let url = navigationAction.request.url!
//
//        if (url.relativeString.hasPrefix(self.urlPrefix)) == true {
//            decisionHandler(.allow)
//        } else {
//            // Handle MMOB Browser here
//            decisionHandler(.cancel)
//            UIApplication.shared.canOpenURL(url)
//            UIApplication.shared.open(url)
//        }
//    }
// }
