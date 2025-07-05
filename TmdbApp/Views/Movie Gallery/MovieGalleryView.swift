//
//  ContentView.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import SwiftUI
import Kingfisher

struct MovieGalleryView: View {
    @Environment(\.darkModeColor) private var color
    @StateObject var viewModel: MovieGalleryViewModel = MovieGalleryViewModel()
    let columns = 3
    
    private var gridItems: [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: 100, maximum: 100), spacing: 16), count: columns)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Menu {
                    Button {
                        viewModel.popularSelected()
                    } label: {
                        Text("Popular")
                    }
                    Button {
                        viewModel.trendingSelected()
                    } label: {
                        Text("Trending")
                    }

                } label: {
                    HStack {
                        Text(viewModel.stateTitle)
                            .foregroundStyle(color)
                            .font(.system(size: 17))
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.down")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 12, height: 8)
                            .foregroundStyle(color)
                    }
                }
                
                Spacer()
                if viewModel.viewState == .trending {
                    Menu {
                        Button(action: {
                            viewModel.trendingTimeChanged(time: .week)
                        }, label: {
                            Text("Week")
                        })
                        Button(action: {
                            viewModel.trendingTimeChanged(time: .day)
                        }, label: {
                            Text("Day")
                        })
                    } label: {
                        HStack {
                            Text(viewModel.trendingStateTitle)
                            Image(systemName: "chevron.down")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 12, height: 8)
                                .foregroundStyle(color)
                        }
                    }
                    .foregroundColor(color)
                    .cornerRadius(8)
                    .shadow(radius: 3)
                }
            }
            ScrollView {
                LazyVGrid(columns: gridItems) {
                    ForEach(viewModel.movieData.indices, id: \.self) { index in
                        NavigationLink(value: viewModel.movieArray[index]) {
                            MoviePosterView(
                                data: viewModel.movieData[index],
                                favoriteAction: { id in
                                    viewModel.manageFavorite(id: id, index: index)
                                }
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .navigationTitle(viewModel.galleryTitleString)
        .navigationBarTitleDisplayMode(.automatic)
        .navigationDestination(for: MovieData.self) { movie in
            MovieDetailsView(
                viewModel:
                    MovieDetailsViewModel(movieObject: movie)
            )
        }
        .alert("Error", isPresented: $viewModel.removeFavAlert, actions: {}, message: {
            Text("Could not remove from favorites. Please try again later.")
        })
        .onAppear {
            viewModel.getMovieSubviewData()
        }
    }
    
    private func numberOfRows() -> Int {
        return (viewModel.movieData.count + columns - 1) / columns
    }
}

private struct MoviePosterView: View {
    @Environment(\.darkModeColor) private var color
    @State private var showFailedAlert: Bool = false
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium, view: UIApplication.shared.connectedScenes
        .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first ?? UIView())
    let data: MovieGalleryViewModel.MovieSubviewData
    let favoriteAction: (Int) -> Void
    
    init(data: MovieGalleryViewModel.MovieSubviewData, favoriteAction: @escaping (Int) -> Void) {
        self.data = data
        self.favoriteAction = favoriteAction
        impactGenerator.prepare()
    }
    
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
        .overlay(alignment: .topTrailing) {
            Button(action: {
                guard let movieId = data.movieId else {
                    showFailedAlert = true
                    return
                }
                favoriteAction(movieId)
                // Haptic feedback since it's so small
                impactGenerator.impactOccurred()
            }, label: {
                Image(systemName: data.isFavorited ? "heart.fill" : "heart")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    //.offset(x: 5, y: 5)
                    .foregroundStyle(data.isFavorited ? .pink : color)
            })
        }
        .alert("Error", isPresented: $showFailedAlert, actions: {}, message: {
            Text("Could not favorite movie. Please try again later.")
        })
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
