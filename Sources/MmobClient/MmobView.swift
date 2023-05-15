//
//  MmobView.swift
//  mmob-tester
//
//  Created by Hasseeb Hussain on 11/05/2023.
//

import SwiftUI
import WebKit

struct MmobView: View {
    let request: URLRequest
    let instanceDomain: String

    var body: some View {
        Text(instanceDomain)
    }
}
