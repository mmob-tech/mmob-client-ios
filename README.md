# MMOB iOS Client 📱

The MMOB iOS Client works across multiple iOS versions from **iOS 12.0** to **iOS 16.\***

## Instructions to implement

### MmobViewController.swift

```swift
//
//  MmobViewController.swift
//

import MmobClient
import UIKit
import WebKit

class MmobViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    var webView: MmobClientView!
    let client = MmobClient()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadView() {
        super.loadView()
        view = getMarketplace()
    }

    func getMarketplace() -> MmobClientView {
        let configuration = MmobIntegration(
            configuration: MmobIntegrationConfiguration(
                cp_id: "YOUR_CP_ID_HERE",
                integration_id: "YOUR_CP_DEPLOYMENT_ID_HERE",
                locale: "en-GB"
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

        return client.loadIntegration(mmobConfiguration: configuration)
    }
}
```

## Instructions to implement using SwiftUI

If you plan on using our client through the SwiftUI framework you will need to follow some extra steps. Once you have created the above `MmobViewController.swift` file follow below

### MmobView.swift

```swift
//
//  MmobView.swift
//

import SwiftUI

struct MmobView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MmobViewController {
        return MmobViewController()
    }

    func updateUIViewController(_ uiViewController: MmobViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}
```

### ContentView.swift

```swift
//
//  ContentView.swift
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MmobView()
    }
}

```
