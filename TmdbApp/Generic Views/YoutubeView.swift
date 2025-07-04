//
//  YoutubeView.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/4/25.
//

import SwiftUI
import WebKit

struct YoutubeView: UIViewRepresentable {
    let videoId: String
    
    func makeUIView(context: Context) ->  WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let demoURL = URL(string: "https://www.youtube.com/embed/\(videoId)") else { return }
        uiView.scrollView.isScrollEnabled = false
        uiView.configuration.allowsInlineMediaPlayback = true
        uiView.load(URLRequest(url: demoURL))
    }
}


