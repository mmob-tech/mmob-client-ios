
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
    let helper = MmobClientHelper()

    public func loadIntegration(mmobConfiguration: MmobIntegration, instanceDomain: String) -> some View {
        let customer = mmobConfiguration.customer
        let company = mmobConfiguration.configuration
        let parameters = self.helper.getIntegrationParameters(company: mmobConfiguration.configuration, customer: customer)
        let url = URL(string: self.helper.getBootUrl(environment: company.environment, instanceDomain: instanceDomain) + "/boot")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
        }

        return MmobView(instanceDomain: instanceDomain, request: request)
    }

    public func loadDistribution(mmobConfiguration: MmobDistribution, instanceDomain: String) -> some View {
        let configuration = mmobConfiguration.configuration
        let customer = mmobConfiguration.customer
        let parameters = self.helper.getDistributionParamaters(customer: customer)
        let url = URL(string: helper.getBootUrl(environment: configuration.environment, instanceDomain: instanceDomain) + "/tpp/distribution/boot")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let bootRequestConfiguration = [
            "distribution_id": configuration.distribution_id,
            "identifier_type": "ios",
            "identifier_value": self.helper.getBundleID()
        ]

        let bootRequest = [
            "configuration": bootRequestConfiguration,
            "customer_info": parameters
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bootRequest, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
        }

        return MmobView(instanceDomain: instanceDomain, request: request)
    }
}
