//
//  MmobClientHelper.swift
//
//
//  Created by Hasseeb Hussain on 22/05/2023.
//

import Foundation

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

class MmobClientHelper {
    func containsAffiliateRedirect(in urlPath: String) -> Bool {
        return urlPath.contains("affiliate-redirect")
    }

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

    func getDistributionParameters(customer: MmobCustomerInfo) -> MmobParameters {
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

    func getInstanceDomain(domain: InstanceDomain) -> String {
        switch domain {
        case InstanceDomain.EFNETWORK:
            return "ef-network.com"
        default:
            return "mmob.com"
        }
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
