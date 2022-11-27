# MmobClient

Since version 0.3.0, the `MmobClient` has been secured to only allow views owned by `mmob` or its distributors. The implementation has suffered some breaking changes.

To declare a new mmob client, follow the example below:

```swift

//
//  MarketplaceView.swift
//  EfHubIOs14
//

import SwiftUI
import MmobClient

struct MarketplaceView: UIViewRepresentable {
    let client = MmobClient()
    func updateUIView(_ uiView: MmobClientView, context: Context) {
        print("update UI")

    }

    func makeUIView(context: Context) -> MmobClientView  {

        let configuration = MmobConfiguration(
            configuration: MmobCompanyConfiguration(
                cp_id: "cp_id",
                integration_id: "cpd_id",
                environment: "stag"

            ),
            customer: MmobCustomerInfo(
                email: "john.smith@example.com",
                first_name: "John",
                surname: "Smith",
                title: "Mr",
                building_number: "Flat 81",
                address_1: "Marconi Square",
                town_city: "Chelmsford",
                postcode: "CM1 1XX"
            )
        )


        return client.getClient(mmobConfiguration: configuration, instanceDomain:"ef-network.com")

    }
}


```
