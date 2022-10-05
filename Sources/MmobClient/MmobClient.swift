
import SwiftUI
import WebKit


public typealias MmobClientView = WKWebView

public struct MmobCustomerInfo {
    public init(email: String, first_name: String? = nil, surname: String? = nil, gender: String? = nil, title: String? = nil, building_number: String? = nil, address_1: String? = nil, town_city: String? = nil, postcode: String? = nil, dob: String? = nil) {
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
    
    var email: String
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

public struct MmobClient {
    
    static func getBundlerId() -> String {
        let bundleID = Bundle.main.bundleIdentifier!
        return bundleID
    }

    static func getUrl(environment: String, suffix: String = "boot", instanceDomain: String = "mmob.com" ) -> URL {
        // Set client url entry point
        let local_url = URL(string: "http://localhost:3100" + "/" + suffix)!
        let dev_url = URL(string: "https://client-ingress.dev." + instanceDomain + "/" + suffix)!
        let stag_url = URL(string: "https://client-ingress.stag." + instanceDomain + "/" + suffix)!
        let prod_url = URL(string: "https://client-ingress.prod." + instanceDomain + "/" + suffix)!
        
        
        switch environment {
        case "local":
            return local_url
        case "dev":
            return dev_url
        case "stag":
            return stag_url
            
        default:
            return prod_url
            
        }
        
    }
    
    
    static func getParameters(customer: MmobCustomerInfo) -> MmobParameters {
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
    
    public static func getDistribution(mmobDistribution: MmobDistribution) -> MmobClientView {
        let view =  WKWebView()
        let configuration = mmobDistribution.configuration
        let customer = mmobDistribution.customer
        
        let url = getUrl(environment: configuration.environment, suffix: "tpp/distribution/boot")
        
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
    
    public static func getClient(mmobConfiguration: MmobConfiguration) -> MmobClientView   {
        
        
        let view =  WKWebView()
        
        
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

        
        let url = getUrl(environment: company.environment)
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        print("url", url)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        view.load(request)
        return view
    }
}
