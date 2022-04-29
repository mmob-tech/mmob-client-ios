
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
    public init(cp: String, integration: String, environment: String = "production") {
        self.cp = cp
        self.integration = integration
        self.production = environment == "production"
    }
    
    var cp: String
    var integration: String
    var production: Bool
}

public struct MmobConfiguration {
    public init(company: MmobCompanyConfiguration, customer_info: MmobCustomerInfo) {
        self.company = company
        self.customer_info = customer_info
    }

    
    var company: MmobCompanyConfiguration
    var customer_info: MmobCustomerInfo
}

public struct MmobClient {

    public static func getClient(mmobConfiguration: MmobConfiguration) -> MmobClientView   {
        
        
        let view =  WKWebView()
        

        let customer_info = mmobConfiguration.customer_info
        let company = mmobConfiguration.company
        

        // Create parameters object
        let parameters: [String: String?] = [
            "email": customer_info.email,
            "first_name": customer_info.first_name,
            "surname": customer_info.surname,
            "title": customer_info.title,
            "building_number": customer_info.building_number,
            "address_1": customer_info.address_1,
            "town_city": customer_info.town_city,
            "postcode": customer_info.postcode,
            "cp_id": company.cp,
            "deployemnt_id": company.integration
        ]
        
        
        // Set client url entry point
        let stag_url = URL(string: "https://client-ingress.stag.mmob.com/boot")!
        let prod_url = URL(string: "https://client-ingress.prod.mmob.com/boot")!
        
        let url = company.production ? prod_url : stag_url
        
        // Configure request
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        

        view.load(request)
        return view
    }
}
