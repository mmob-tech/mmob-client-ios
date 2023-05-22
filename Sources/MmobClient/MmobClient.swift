
import SwiftUI
import WebKit

public class MmobClient: UIViewController {
    let helper = MmobClientHelper()

    public func loadIntegration(mmobConfiguration: MmobIntegration, instanceDomain: InstanceDomain) -> some View {
        let customer = mmobConfiguration.customer
        let company = mmobConfiguration.configuration
        let parameters = self.helper.getIntegrationParameters(company: mmobConfiguration.configuration, customer: customer)
        let instanceDomainString = self.helper.getInstanceDomain(domain: instanceDomain)
        let url = URL(string: self.helper.getBootUrl(environment: company.environment, instanceDomain: instanceDomainString) + "/boot")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
        }

        return MmobView(instanceDomain: instanceDomainString, request: request)
    }

    public func loadDistribution(mmobConfiguration: MmobDistribution, instanceDomain: InstanceDomain) -> some View {
        let configuration = mmobConfiguration.configuration
        let customer = mmobConfiguration.customer
        let parameters = self.helper.getDistributionParamaters(customer: customer)
        let instanceDomainString = self.helper.getInstanceDomain(domain: instanceDomain)
        let url = URL(string: helper.getBootUrl(environment: configuration.environment, instanceDomain: instanceDomainString) + "/tpp/distribution/boot")!

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

        return MmobView(instanceDomain: instanceDomainString, request: request)
    }
}
