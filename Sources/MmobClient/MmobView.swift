//
//  MmobView.swift
//
//
//  Created by Hasseeb Hussain on 16/05/2023.
//

import SwiftUI
import WebKit

struct MmobView: View {
    let instanceDomain: String

    @State var request: URLRequest
    @State var isNotInstanceDomain: Bool = false

    var body: some View {
        WebView(instanceDomain: instanceDomain, request: $request, isNotInstanceDomain: $isNotInstanceDomain)
            .compatibleFullScreen(isPresented: $isNotInstanceDomain, content: {
                BrowserView(instanceDomain: instanceDomain, request: $request, isNotInstanceDomain: $isNotInstanceDomain)
            })
    }
}

struct BrowserView: View {
    let instanceDomain: String

    @Binding var request: URLRequest
    @Binding var isNotInstanceDomain: Bool

    var body: some View {
        browserView()
    }

    func browserView() -> some View {
        let webView = WebView(instanceDomain: instanceDomain, request: $request, isNotInstanceDomain: $isNotInstanceDomain)

        return
            VStack {
                HeaderView(webView: webView)
                webView
                FooterView(webView: webView)
            }
    }
}

struct HeaderView: View {
    let webView: WebView

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 16)
            }
            VStack(spacing: 3) {
                Text(webView.title())
                    .font(.body)
                    .bold()
                HStack {
                    Image(systemName: "lock.fill")
                        .padding(.trailing, -5)
                        .imageScale(.small)
                        .foregroundColor(Color(hex: "#7F8794"))
                    Text(verbatim: webView.URL())
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
    let webView: WebView

    var body: some View {
        HStack {
            Button(action: {
                webView.goBack()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(webView.canGoBack() ? Color(hex: "#7F8794") : Color(hex: "#CED4DD"))
                    .imageScale(.large)
            }
//            .disabled(!webView.canGoBack())

            Spacer()

            Button(action: {
                webView.goForward()
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(webView.canGoForwards() ? Color(hex: "#7F8794") : Color(hex: "#CED4DD"))
                    .imageScale(.large)
            }
//            .disabled(!webView.canGoForwards())
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

extension View {
    func compatibleFullScreen<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        modifier(FullScreenModifier(isPresented: isPresented, builder: content))
    }
}

struct FullScreenModifier<V: View>: ViewModifier {
    let isPresented: Binding<Bool>
    let builder: () -> V

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content.fullScreenCover(isPresented: isPresented, content: builder)
        } else {
            content.sheet(isPresented: isPresented, content: builder)
        }
    }
}
