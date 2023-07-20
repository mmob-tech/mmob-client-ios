//
//  MmobClientHelper.swift
//
//
//  Created by Hasseeb Hussain on 22/05/2023.
//

import Foundation
import SwiftUI

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

public enum InstanceDomain {
    case MMOB, EFNETWORK
}

public struct MmobIntegrationConfiguration {
    var cp_id: String
    var integration_id: String
    var environment: String
    var locale: String

    public init(cp_id: String, integration_id: String, environment: String = "production", locale: String = "en_GB") {
        self.cp_id = cp_id
        self.integration_id = integration_id
        self.environment = environment
        self.locale = locale
    }
}

public struct MmobDistributionConfiguration {
    var distribution_id: String
    var environment: String
    var locale: String

    public init(distribution_id: String, environment: String = "production", locale: String = "en_GB") {
        self.distribution_id = distribution_id
        self.environment = environment
        self.locale = locale
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

typealias MmobParameters = [String: Any?]

class MmobClientHelper {
    func containsAffiliateRedirect(in urlPath: String) -> Bool {
        return urlPath.contains("affiliate-redirect")
    }

    private func getBundleID() -> String {
        let bundleID = Bundle.main.bundleIdentifier!
        return bundleID
    }

    func getDistributionParameters(configuration: MmobDistributionConfiguration, customer: MmobCustomerInfo) -> MmobParameters {
        let parameters: MmobParameters = [
            "email": customer.email,
            "first_name": customer.first_name,
            "surname": customer.surname,
            "title": customer.title,
            "building_number": customer.building_number,
            "address_1": customer.address_1,
            "town_city": customer.town_city,
            "postcode": customer.postcode,
            "configuration": [
                "distribution_id": configuration.distribution_id,
                "identifier_type": "ios",
                "identifier_value": getBundleID(),
                "locale": configuration.locale
            ]
        ]

        return parameters
    }

    func getHost(from url: String?) -> String? {
        guard let url = url else {
            return nil
        }

        guard let parsedUrl = URL(string: url) else {
            return nil
        }

        return parsedUrl.host
    }

    func getInstanceDomain(instanceDomain: InstanceDomain) -> String {
        switch instanceDomain {
        case InstanceDomain.EFNETWORK:
            return "ef-network.com"
        default:
            return "mmob.com"
        }
    }

    func getIntegrationParameters(configuration: MmobIntegrationConfiguration, customer: MmobCustomerInfo) -> MmobParameters {
        let parameters: [String: String?] = [
            "email": customer.email,
            "first_name": customer.first_name,
            "surname": customer.surname,
            "title": customer.title,
            "building_number": customer.building_number,
            "address_1": customer.address_1,
            "town_city": customer.town_city,
            "postcode": customer.postcode,
            "cp_id": configuration.cp_id,
            "cp_deployment_id": configuration.integration_id,
            "locale": configuration.locale
        ]

        return parameters
    }

    func getRequest(url: URL, parameters: MmobParameters) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print(error.localizedDescription)
        }

        return request
    }

    func getRootDomain(from uri: URL) -> String? {
        guard let host = uri.host else {
            return nil
        }

        let components = host.components(separatedBy: ".")

        guard components.count >= 2 else {
            return nil
        }

        let rootDomain = components[components.count - 2] + "." + components[components.count - 1]

        return rootDomain
    }

    func getUrl(environment: String, instanceDomain: InstanceDomain, suffix: String = "boot") -> URL {
        let instanceDomainString = getInstanceDomain(instanceDomain: instanceDomain)

        switch environment {
        case "local":
            return URL(string: "http://localhost:3100/\(suffix)")!
        case "dev":
            return URL(string: "https://client-ingress.dev.\(instanceDomainString)/\(suffix)")!
        case "stag":
            return URL(string: "https://client-ingress.stag.\(instanceDomainString)/\(suffix)")!
        default:
            return URL(string: "https://client-ingress.prod.\(instanceDomainString)/\(suffix)")!
        }
    }

    // https://stackoverflow.com/a/58622251
    func getTopMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while topController.presentedViewController != nil {
            topController = topController.presentedViewController!
        }
        return topController
    }

    func setDefaultWebViewValues(title: UILabel, subtitle: UILabel) {
        title.text = "Loading..."
        subtitle.text = "Loading webpage..."
    }

    func setWebViewTitle(webViewTitle: UILabel, title: String, url: String) {
        if url.hasPrefix("https://") {
            let image = UIImage(named: "lock.fill")

            let imageAttachment = NSTextAttachment()
            imageAttachment.image = image

            let imageSize = CGSize(width: 12, height: 12)
            imageAttachment.bounds = CGRect(origin: .zero, size: imageSize)

            let attributedString = NSMutableAttributedString(string: "")
            let imageAttributedString = NSAttributedString(attachment: imageAttachment)
            attributedString.append(imageAttributedString)
            attributedString.append(NSAttributedString(string: " \(title)"))

            webViewTitle.attributedText = attributedString
        }
    }
}
