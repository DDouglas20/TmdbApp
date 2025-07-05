//
//  HomeView.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/4/25.
//

import SwiftUI

struct DarkModeColorKey: EnvironmentKey {
    static let defaultValue: Color = .black
}

extension EnvironmentValues {
    var darkModeColor: Color {
        get { self[DarkModeColorKey.self] }
        set { self[DarkModeColorKey.self] = newValue }
    }
}

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = HomeViewModel()
    
    var darkModeColor: Color {
        return colorScheme == .light ? .black : .white
    }
    var body: some View {
        if viewModel.isLoading {
            // TODO: Shimmer view maybe?
            ProgressView()
                .tint(darkModeColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    Task {
                        await viewModel.loadMovies()
                    }
                }
        } else {
            TabView {
                Tab("Home", systemImage: "house", content: {
                    NavigationStack {
                        MovieGalleryView()
                    }
                })
                Tab("Favorites", systemImage: "heart.fill", content: {
                    NavigationStack {
                        FavoritesView()
                    }
                })
            }
            .environment(\.darkModeColor, colorScheme == .light ? .black : .white) // Light and Dark mode support
        }
    }
}

#Preview {
    HomeView()
}
