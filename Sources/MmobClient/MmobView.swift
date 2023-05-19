//
//  MmobView.swift
//
//
//  Created by Hasseeb Hussain on 16/05/2023.
//

import SwiftUI

struct MmobView: View {
    let request: URLRequest
    let instanceDomain: String

    var body: some View {
        WebView(request: request, instanceDomain: instanceDomain)
    }
}
