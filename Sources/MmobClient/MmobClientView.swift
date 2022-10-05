//
//  SwiftUIView.swift
//  
//
//  Created by Blai Pratdesaba Pares on 29/04/2022.
//
#if os(iOS)
import SwiftUI
import WebKit

@available(iOS 14.0, *)
struct MarketplaceView: UIViewRepresentable {
    // broadband | energy
    public private(set) var page: String = "broadband"
    
    public private(set) var email: String = "-"
    public private(set) var first_name: String = "-"
    public private(set) var surname: String = "-"
    public private(set) var title: String = "-"
    public private(set) var building_number: String = "-"
    public private(set) var town_city: String = "-"
    public private(set) var postcode: String = "-"
    public private(set) var address_1: String = "-"
    
    
    func makeUIView(context: Context, domainInstance: String = "mmob.com") -> WKWebView  {
        
        
        let view =  WKWebView()
        

        // Create parameters object
        let parameters: [String: String] = [
            "email": email,
            "first_name": first_name,
            "surname": surname,
            "title": title,
            "building_number": building_number,
            "address_1": address_1,
            "town_city": town_city,
            "postcode": postcode,
            
            "cp_id": "cp_DhskfrQ5V0HLfcVwbl54Q",
            "page": self.page
        ]
        
        
        // Set marketplace url entry point
        let url = URL(string: "https://marketplace-ingress.demo." + domainInstance + "/boot")!
        
        
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
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        print("update UI")
        
    }
}

struct MarketplaceView_Previews: PreviewProvider {
    static var previews: some View {
        MarketplaceView()
    }
}
#endif
