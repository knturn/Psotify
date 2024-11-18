//
//  LoginView.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI

struct LoginView: View {
    @State private var showWebView = false
    @ObservedObject private var viewModel: LoginViewModel
    
    init(showWebView: Bool = false, viewModel: LoginViewModel) {
        self.showWebView = showWebView
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            backgroundColor
            content
        }
        .ignoresSafeArea()
    }
    
    private var backgroundColor: Color {
        Color.black
    }
    @ViewBuilder
    private var content: some View {
        if showWebView {
            webViewContent
        } else {
            VStack{
                Images.loginLogo.image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8,
                           maxHeight: UIScreen.main.bounds.height * 0.8)
                    .ignoresSafeArea()
                Spacer()
                signInButton
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 15)
            }
        }
        
    }
    
    private var webViewContent: some View {
        Group {
            if let url = viewModel.getSpotifyAuthURL() {
                WebView(url: url) { authCodeURL in
                    viewModel.handleLogin(with: authCodeURL)
                }
                .edgesIgnoringSafeArea(.all)
            } else {
                Text("Yönlendirme BAŞARISIZ oldu")
                    .foregroundColor(.red)
            }
        }
    }
    
    private var signInButton: some View {
        Button(action: {
            showWebView.toggle()
        }) {
            Text("Sign In")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity) 
                .background(Color.green)
                .cornerRadius(8)
        }
        .padding(.bottom, 50)
        .padding(.leading, 15)
        .padding(.trailing, 15)
    }
}
