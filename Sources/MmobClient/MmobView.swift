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
    @ObservedObject private var model: WebViewModel = .init()
    @State private var isNotInstanceDomain: Bool = false

    var body: some View {
        ZStack {
            WebView(request: request, instanceDomain: instanceDomain, model: model, isNotInstanceDomain: $isNotInstanceDomain)
                .compatibleFullScreen(isPresented: $isNotInstanceDomain, content: {
                    BrowserView(request: request, instanceDomain: instanceDomain, isNotInstanceDomain: $isNotInstanceDomain)
                })
                
        }
    }
}

struct BrowserView: View {
    let request: URLRequest
    let instanceDomain: String
    @ObservedObject private var model: WebViewModel = .init()
    @Binding var isNotInstanceDomain: Bool

    let tempRequest: URLRequest = .init(url: URL(string: "https://google.com")!)

    var body: some View {
        VStack {
            HeaderView(model: model, title: model.title, subtitle: model.url)
            WebView(request: tempRequest, instanceDomain: instanceDomain, model: model, isNotInstanceDomain: $isNotInstanceDomain)
            FooterView(model: model, canGoBack: model.canGoBack, canGoForward: model.canGoForward)
        }
    }
}

struct HeaderView: View {
    let model: WebViewModel
    let title: String
    let subtitle: String
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



extension View {
    func compatibleFullScreen<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(FullScreenModifier(isPresented: isPresented, builder: content))
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
