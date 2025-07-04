//
//  ContentView.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import SwiftUI
import Kingfisher

struct DarkModeColorKey: EnvironmentKey {
    static let defaultValue: Color = .black
}

extension EnvironmentValues {
    var darkModeColor: Color {
        get { self[DarkModeColorKey.self] }
        set { self[DarkModeColorKey.self] = newValue }
    }
}

struct MovieGalleryView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = MovieGalleryViewModel()
    @State var isLoading: Bool = false
    
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
                        MovieGallerySubview(data: viewModel.returnMovieSubviewData(), titleString: viewModel.galleryTitleString)
                            
                    }
                })
                Tab("Favorites", systemImage: "heart.fill", content: {
                    FavoritesView()
                })
            }
            .environment(\.darkModeColor, colorScheme == .light ? .black : .white) // Light and Dark mode support
        }
    }
}

private struct MovieGallerySubview: View {
    let data: [MovieGalleryViewModel.MovieSubviewData]
    let titleString: String
    let columns = 3
    
    private var gridItems: [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: 100, maximum: 100), spacing: 16), count: columns)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems) {
                ForEach(data.indices, id: \.self) { index in
                    NavigationLink(value: DataManager.shared.popularMovies[index]) {
                        MoviePosterView(data: data[index])
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(titleString)
        .navigationBarTitleDisplayMode(.automatic)
        .navigationDestination(for: MovieData.self) { movie in
            MovieDetailsView(
                viewModel:
                    MovieDetailsViewModel(movieObject: movie)
            )
        }
    }
    
    private func numberOfRows() -> Int {
        return (data.count + columns - 1) / columns
    }
}

private struct MoviePosterView: View {
    @Environment(\.darkModeColor) private var color
    let data: MovieGalleryViewModel.MovieSubviewData
    var body: some View {
        VStack(alignment: .leading) {
            if let urlString = data.imageUrl, let url = URL(string: urlString) {
                KFImage(url)
                    .resizable()
                    .placeholder({ _ in
                        ProgressView()
                            .tint(color)
                    })
                    .scaledToFit()
                    .frame(width: 100, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 4.0))
                    .shadow(color: color.opacity(0.4), radius: 6.0, x: 0, y: 4)
            } else {
                Image(systemName: "photo.fill")
                    .frame(width: 100, height: 150)
                    .border(color)
            }
            if let movieName = data.title {
                Text(movieName)
                    .font(.system(size: 10))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(color)
            }
            if let movieRating = data.rating {
                HStack(spacing: 4) {
                    Image(systemName: getRatingImageName(for: movieRating))
                        .resizable()
                        .foregroundStyle(.yellow)
                        .frame(width: 10, height: 10)
                    Text(String(format: "%.1f", movieRating))
                        .font(.system(size: 10))
                        .foregroundStyle(color)
                }
            }
            Spacer()
        }
        .frame(width: 100, height: 225)
    }
    
    private func getRatingImageName(for rating: Double) -> String {
        if rating >= 4.0 {
            return "star.fill"
        } else if rating >= 2.0 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

//#Preview {
//    MovieGalleryView()
//}
