//
//  LoginView.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI

struct LoginView: View {
    
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
    
    private var signInButton: some View {
        Button(action: {
            print("Tapped")
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
