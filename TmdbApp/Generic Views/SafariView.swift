//
//  SafariView.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/4/25.
//

import SwiftUI
import SafariServices

struct SFSafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> UIViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Nothing to update
    }
}
