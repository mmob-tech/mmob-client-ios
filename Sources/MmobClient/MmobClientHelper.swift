//
//  MmobClientHelper.swift
//
//
//  Created by Hasseeb Hussain on 22/05/2023.
//

import Foundation
import SwiftUI
import WebKit
import UIKit

@objcMembers
public class MmobCustomerInfo: NSObject {
    @objc var email: String?
    @objc var first_name: String?
    @objc var surname: String?
    @objc var gender: String?
    @objc var title: String?
    @objc var building_number: String?
    @objc var address_1: String?
    @objc var town_city: String?
    @objc var postcode: String?
    @objc var dob: String?

    @objc public init(email: String? = nil, first_name: String? = nil, surname: String? = nil, gender: String? = nil, title: String? = nil, building_number: String? = nil, address_1: String? = nil, town_city: String? = nil, postcode: String? = nil, dob: String? = nil) {
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

@objc
public enum InstanceDomain:Int {
    case MMOB, EFNETWORK
}

@objcMembers
public class MmobIntegrationConfiguration: NSObject {
    @objc var cp_id: String
    @objc var integration_id: String
    @objc var environment: String
    @objc var locale: String

    @objc public init(cp_id: String, integration_id: String, environment: String = "production", locale: String = "en_GB") {
        self.cp_id = cp_id
        self.integration_id = integration_id
        self.environment = environment
        self.locale = locale
    }
}

@objcMembers
public class MmobDistributionConfiguration:NSObject {
    @objc var distribution_id: String
    @objc var environment: String
    @objc var locale: String

    @objc public init(distribution_id: String, environment: String = "production", locale: String = "en_GB") {
        self.distribution_id = distribution_id
        self.environment = environment
        self.locale = locale
    }
}

@objcMembers
public class MmobIntegration:NSObject {
    @objc var configuration: MmobIntegrationConfiguration
    @objc var customer: MmobCustomerInfo

    @objc public init(configuration: MmobIntegrationConfiguration, customer: MmobCustomerInfo) {
        self.configuration = configuration
        self.customer = customer
    }
}

@objcMembers
public class MmobDistribution:NSObject {
    @objc var configuration: MmobDistributionConfiguration
    @objc var customer: MmobCustomerInfo

    @objc public init(configuration: MmobDistributionConfiguration, customer: MmobCustomerInfo) {
        self.configuration = configuration
        self.customer = customer
    }
}

typealias MmobParameters = [String: Any?]

@objcMembers
public class MmobClientHelper:NSObject {
    let AFFILIATE_REDIRECT_PATH = "affiliate-redirect"
    let MMOB_ROOT_DOMAIN = "mmob.com"
    let EFNETWORK_ROOT_DOMAIN = "ef-network.com"
    let BLACKLISTED_DOMAINS = ["apps.apple.com"]

    func containsAffiliateRedirect(in urlPath: String) -> Bool {
        return urlPath.contains(AFFILIATE_REDIRECT_PATH)
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
            return EFNETWORK_ROOT_DOMAIN
        default:
            return MMOB_ROOT_DOMAIN
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

    func isBlacklistedDomain(url: URL) -> Bool {
        if let host = getHost(from: url.absoluteString) {
            return BLACKLISTED_DOMAINS.contains(host)
        } else {
            return false
        }
    }

    func isValidURL(url: URL) -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }

    func isValidUrlScheme(url: URL) -> Bool {
        let urlString = url.absoluteString
        return urlString.hasPrefix("http://") || urlString.hasPrefix("https://")
    }

    func setDefaultWebViewValues(title: UILabel, subtitle: UILabel) {
        title.text = "Loading..."
        subtitle.text = "Loading webpage..."
    }

    func setWebViewTitle(webViewTitle: UILabel, title: String, url: String) {
        if url.hasPrefix("https://") {
            let symbolImage = UIImage(named: "lock.fill")
            var selectedImage = symbolImage

            // TODO: Find appropriate solution for < iOS 13. Currently will return black icon
            if #available(iOS 13.0, *) {
                selectedImage = symbolImage?.withTintColor(UIColor(named: "Grey4")!, renderingMode: .alwaysTemplate)
            }

            // Now, use 'tintedImage' to create NSTextAttachment
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = selectedImage

            let imageSize = CGSize(width: 12, height: 12)
            imageAttachment.bounds = CGRect(origin: .zero, size: imageSize)

            let attributedString = NSMutableAttributedString(string: "")
            let imageAttributedString = NSAttributedString(attachment: imageAttachment)
            attributedString.append(imageAttributedString)
            attributedString.append(NSAttributedString(string: " \(title)"))

            webViewTitle.attributedText = attributedString
        } else {
            webViewTitle.text = title
        }
    }
}
