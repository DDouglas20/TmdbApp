//
//  MovieGalleryViewModel.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation
import SwiftUI

class MovieGalleryViewModel: ObservableObject {
    
    // MARK: Properties
    
    @Published var isLoading: Bool = true
    
    @Published var movies: [MovieData] = []
    
    var viewState: ViewState = .popular
    
    var topRatedState: TopRatedState = .week
    
    @Published var movieData: [MovieSubviewData] = []
    
    @Published var removeFavAlert: Bool = false
    
    struct MovieSubviewData: Hashable {
        let id = UUID().uuidString
        let movieId: Int?
        let imageUrl: String?
        let title: String?
        let rating: Double?
        var isFavorited: Bool
    }
    
    var galleryTitleString: String {
        return viewState == .popular ? "Most Popular Movies" : "Top Rated Movies \(topRatedState == .day ? "Today" : "This Week")"
    }
  
    // MARK: Functions
    func getMovieSubviewData() {
        var movieArray = [MovieSubviewData]()
        for movie in DataManager.shared.popularMovies {
            movieArray.append(
                .init(
                    movieId: movie.id,
                    imageUrl: ApiClient.baseImageURL + (movie.portaitPath ?? ""),
                    title: movie.movieName,
                    rating: movie.movieRating,
                    isFavorited: favList.contains(movie.id ?? -1)
                )
            )
        }
        movieData = movieArray
    }
    
//    func addFavorite(id: Int, index: Int) {
//        var favoritesArr = favList
//        favoritesArr.append(id)
//        UserDefaults.standard.set(favoritesArr, forKey: DataManager.favoritesKey)
//        withAnimation {
//            movieData[index].isFavorited = true
//        }
//    }
//    
//    func removeFavorite(id: Int, index: Int) {
//        var favoritesArr = favList
//        if let favIndex = favoritesArr.firstIndex(of: id) {
//            favoritesArr.remove(at: favIndex)
//            UserDefaults.standard.set(favoritesArr, forKey: DataManager.favoritesKey)
//            withAnimation(.bouncy(duration: 0.2)) {
//                movieData[index].isFavorited = false
//            }
//            return
//        }
//        removeFavAlert = true
//    }
    
    enum ViewState {
        case popular
        case topRated
    }
    
    enum TopRatedState {
        case day
        case week
    }
    
}

extension MovieGalleryViewModel: FavoriteManager {
    func manageFavorite(id: Int, index: Int) {
        var favoritesArr = favList
        var isSelected = favoritesArr.contains(id)
        print("isSelected: \(isSelected)")
        if isSelected {
            if let favIndex = favoritesArr.firstIndex(of: id) {
                favoritesArr.remove(at: favIndex)
                UserDefaults.standard.set(favoritesArr, forKey: DataManager.favoritesKey)
                withAnimation(.bouncy(duration: 0.2)) {
                    movieData[index].isFavorited = false
                }
                return
            }
            removeFavAlert = true
        } else {
            favoritesArr.append(id)
            UserDefaults.standard.set(favoritesArr, forKey: DataManager.favoritesKey)
            withAnimation(.bouncy(duration: 0.2)) {
                movieData[index].isFavorited = true
            }
        }
    }
}
