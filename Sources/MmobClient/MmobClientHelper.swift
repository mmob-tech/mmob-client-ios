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
    @objc var  email: String?
    @objc var  title: String?
    @objc var first_name: String?
    @objc var  surname: String?
     @objc var  dob: String?
     @objc var  phone_number: String?
     @objc var  mobile_number: String?
     @objc var  preferred_name: String?
     @objc var  passport_number: String?
     @objc var  national_insurance_number: String?
     @objc var  building_number: String?
     @objc var  address_1: String?
     @objc var  address_2: String?
     @objc var  address_3: String?
     @objc var  town_city: String?
     @objc var  county: String?
     @objc var  postcode: String?
     @objc var  country_of_residence: String?
     @objc var  nationality: String?
     @objc var  gender: String?
     @objc var  relationship_status: String?
     @objc var  number_of_children: Int
     @objc var  partner_first_name: String?
     @objc var  partner_surname: String?
     @objc var  partner_dob: String?
     @objc var  partner_sex: String?
     @objc var  relationship_to_partner: String?
     @objc var  smoker: String?
     @objc var  number_of_cigarettes_per_week: Int
     @objc var  drinker: String?
     @objc var  number_of_units_per_week: Int
     @objc var  meta: [String: Any]?

    @objc public init(
        email: String? = nil,
        title: String? = nil,
        first_name: String? = nil,
        surname: String? = nil,
        dob: String? = nil,
        phone_number: String? = nil,
        mobile_number: String? = nil,
        preferred_name: String? = nil,
        passport_number: String? = nil,
        national_insurance_number: String? = nil,
        building_number: String? = nil,
        address_1: String? = nil,
        address_2: String? = nil,
        address_3: String? = nil,
        town_city: String? = nil,
        county: String? = nil,
        postcode: String? = nil,
        country_of_residence: String? = nil,
        nationality: String? = nil,
        gender: String? = nil,
        relationship_status: String? = nil,
        number_of_children: Int = 0,
        partner_first_name: String? = nil,
        partner_surname: String? = nil,
        partner_dob: String? = nil,
        partner_sex: String? = nil,
        relationship_to_partner: String? = nil,
        smoker: String? = nil,
        number_of_cigarettes_per_week: Int = 0,
        drinker: String? = nil,
        number_of_units_per_week: Int = 0,
        meta: [String: Any]? = nil
    ) {
        self.email = email
        self.title = title
        self.first_name = first_name
        self.surname = surname
        self.dob = dob
        self.phone_number = phone_number
        self.mobile_number = mobile_number
        self.preferred_name = preferred_name
        self.passport_number = passport_number
        self.national_insurance_number = national_insurance_number
        self.building_number = building_number
        self.address_1 = address_1
        self.address_2 = address_2
        self.address_3 = address_3
        self.town_city = town_city
        self.county = county
        self.postcode = postcode
        self.country_of_residence = country_of_residence
        self.nationality = nationality
        self.gender = gender
        self.relationship_status = relationship_status
        self.number_of_children = number_of_children
        self.partner_first_name = partner_first_name
        self.partner_surname = partner_surname
        self.partner_dob = partner_dob
        self.partner_sex = partner_sex
        self.relationship_to_partner = relationship_to_partner
        self.smoker = smoker
        self.number_of_cigarettes_per_week = number_of_cigarettes_per_week
        self.drinker = drinker
        self.number_of_units_per_week = number_of_units_per_week
        self.meta = meta
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
    @objc var signature: String?

    @objc public init(cp_id: String, integration_id: String, environment: String = "production", locale: String = "en_GB", signature: String? = nil) {
        self.cp_id = cp_id
        self.integration_id = integration_id
        self.environment = environment
        self.locale = locale
        self.signature = signature
    }
}

@objcMembers
public class MmobDistributionConfiguration:NSObject {
    @objc var distribution_id: String
    @objc var environment: String
    @objc var locale: String
    @objc var signature: String?

    @objc public init(distribution_id: String, environment: String = "production", locale: String = "en_GB", signature: String? = nil) {
        self.distribution_id = distribution_id
        self.environment = environment
        self.locale = locale
        self.signature = signature
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

      // Domains we want opened using native URL scheme (aka Safari)
      let BLACKLISTED_DOMAINS = ["apps.apple.com"]

      func containsAffiliateRedirect(in urlPath: String) -> Bool {
          return urlPath.contains(AFFILIATE_REDIRECT_PATH)
      }

      func containsLocalLink(in urlPath: String) -> Bool {
          if let url = URL(string: urlPath), let host = url.host, let port = url.port {
              return host == "localhost" && port == 3100
          }

          return false
      }

      private func getBundleID() -> String {
          let bundleID = Bundle.main.bundleIdentifier!
          return bundleID
      }

      private func getCustomerInfoParameters(customer: MmobCustomerInfo) -> MmobParameters {
          let parameters: MmobParameters = [
              "email": customer.email,
              "title": customer.title,
              "first_name": customer.first_name,
              "surname": customer.surname,
              "dob": customer.dob,
              "phone_number": customer.phone_number,
              "mobile_number": customer.mobile_number,
              "preferred_name": customer.preferred_name,
              "passport_number": customer.passport_number,
              "national_insurance_number": customer.national_insurance_number,
              "building_number": customer.building_number,
              "address_1": customer.address_1,
              "address_2": customer.address_2,
              "address_3": customer.address_3,
              "town_city": customer.town_city,
              "county": customer.county,
              "postcode": customer.postcode,
              "country_of_residence": customer.country_of_residence,
              "nationality": customer.nationality,
              "gender": customer.gender,
              "relationship_status": customer.relationship_status,
              "number_of_children": customer.number_of_children,
              "partner_first_name": customer.partner_first_name,
              "partner_surname": customer.partner_surname,
              "partner_dob": customer.partner_dob,
              "partner_sex": customer.partner_sex,
              "relationship_to_partner": customer.relationship_to_partner,
              "smoker": customer.smoker,
              "number_of_cigarettes_per_week": customer.number_of_cigarettes_per_week,
              "drinker": customer.drinker,
              "number_of_units_per_week": customer.number_of_units_per_week,
              "meta": customer.meta
          ]

          // Filter nil values
          return parameters.filter { $0.value != nil }
      }

      func getDistributionParameters(configuration: MmobDistributionConfiguration, customer: MmobCustomerInfo) -> MmobParameters {
          let customerInfoParameters = getCustomerInfoParameters(customer: customer)
          var parameters: MmobParameters = [
              "configuration": [
                  "distribution_id": configuration.distribution_id,
                  "locale": configuration.locale,
                  "signature": configuration.signature,
                  "identifier_type": "ios",
                  "identifier_value": getBundleID()
              ]
          ]
          parameters.merge(customerInfoParameters) { _, new in new }

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
          let customerInfoParameters = getCustomerInfoParameters(customer: customer)
          var parameters: MmobParameters = [
              "cp_id": configuration.cp_id,
              "cp_deployment_id": configuration.integration_id,
              "locale": configuration.locale,
              "signature": configuration.signature,
              "identifier_type": "ios",
              "identifier_value": getBundleID()
          ]
          parameters.merge(customerInfoParameters) { _, new in new }

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
