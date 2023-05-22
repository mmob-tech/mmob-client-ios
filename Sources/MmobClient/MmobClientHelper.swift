//
//  MmobClientHelper.swift
//
//
//  Created by Hasseeb Hussain on 22/05/2023.
//

import Foundation

class MmobClientHelper {
    func getBootUrl(environment: String, instanceDomain: String) -> String {
        switch environment {
        case "local":
            return "http://localhost:3100/"
        case "dev":
            return "https://client-ingress.dev." + instanceDomain
        case "stag":
            return "https://client-ingress.stag." + instanceDomain
        default:
            return "https://client-ingress.prod." + instanceDomain
        }
    }

    func getBundleID() -> String {
        let bundleID = Bundle.main.bundleIdentifier!
        return bundleID
    }

    func getDistributionParamaters(customer: MmobCustomerInfo) -> MmobParameters {
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

    func getHost(from url: String?) -> String? {
        guard let url = url else {
            return nil
        }

        guard let parsedUrl = URL(string: url) else {
            return nil
        }

        return parsedUrl.host
    }

    func getIntegrationParameters(company: MmobIntegrationConfiguration, customer: MmobCustomerInfo) -> MmobParameters {
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

        return parameters
    }

    func getRootDomain(from url: String) -> String? {
        guard let url = Foundation.URL(string: url),
              let host = url.host
        else {
            return nil
        }

        var components = host.components(separatedBy: ".")

        // Remove subdomains if present
        while components.count > 2 {
            components.removeFirst()
        }

        return components.joined(separator: ".")
    }
}
