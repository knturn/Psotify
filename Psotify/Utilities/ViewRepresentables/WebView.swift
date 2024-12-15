//
//  WebView.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    let handleURL: (URL) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, handleURL: handleURL)
    }
}

// MARK: - Coordinator
extension WebView {
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var handleURL: (URL) -> Void

        init(_ parent: WebView, handleURL: @escaping (URL) -> Void) {
            self.parent = parent
            self.handleURL = handleURL
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            guard let url = webView.url else { return }
            handleURL(url)
        }
    }
}

