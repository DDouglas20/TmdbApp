//
//  ContentView.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import SwiftUI

struct MovieGalleryView: View {
    @State var isLoading: Bool = false
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tint(.green)
            }
        }
        .padding()
        .onTapGesture {
            print("tapped")
            isLoading = true
            Task {
                await ApiClient.shared.loadEnrichedPopularMovies()
                isLoading = false
                print("Data Manager stuff:\n\(DataManager.shared.popularMovies)")
            }
            
        }
    }
}

#Preview {
    MovieGalleryView()
}
