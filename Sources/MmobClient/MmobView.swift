//
//  MmobView.swift
//
//
//  Created by Hasseeb Hussain on 16/05/2023.
//

import SwiftUI

struct MmobView: View {
    @ObservedObject var model: WebViewModel = .init()
    @State private var isInstanceDomain: Bool = true

    let request: URLRequest
    let instanceDomain: String

    var body: some View {
        WebView(model: model, isInstanceDomain: $isInstanceDomain, request: request, instanceDomain: instanceDomain)
    }
}

struct HeaderView: View {
    let model: WebViewModel
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Button(action: {
                    model.goBack()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 16)
            }
            VStack(spacing: 3) {
                Text(model.title)
                    .font(.body)
                    .bold()
                HStack {
                    Image(systemName: "lock.fill")
                        .padding(.trailing, -5)
                        .imageScale(.small)
                        .foregroundColor(Color(hex: "#7F8794"))
                    Text(verbatim: model.url)
                        .font(.caption)
                        .foregroundColor(Color(hex: "#7F8794"))
                }
            }
            .padding(.top, 8)
        }
        .frame(height: 50)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(hex: "#E2E9EE"))
                .padding(.top, 65)
        )
    }
}

struct FooterView: View {
    let model: WebViewModel
    let canGoBack: Bool
    let canGoForward: Bool

    var body: some View {
        HStack {
            Button(action: {
                model.goBack()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(canGoBack ? Color(hex: "#7F8794") : Color(hex: "#CED4DD"))
                    .imageScale(.large)
            }
            .disabled(!canGoBack)

            Spacer()

            Button(action: {
                model.goForward()
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(canGoForward ? Color(hex: "#7F8794") : Color(hex: "#CED4DD"))
                    .imageScale(.large)
            }
            .disabled(!canGoForward)
        }
        .padding([.leading, .trailing], 16)
        .padding(.top, -16)
        .frame(height: 40)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(hex: "#E2E9EE"))
                .padding(.bottom, 55)
        )
    }
}
