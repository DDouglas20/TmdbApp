//
//  FavoritesViewModel.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation

class FavoritesViewModel: ObservableObject {
    // MARK: Properties
    @Published var sortedMovies: [MovieData] = []
    @Published var removeFavAlert: Bool = false
    
    // MARK: Init
    init() {
        getFavoriteMoviesArr()
    }
    
    // MARK: Functions
    func getFavoriteMoviesArr() {
        if let idArr = UserDefaults.standard.value(forKey: DataManager.favoritesKey) as? [Int] {
            var arr: [MovieData] = [] // We use a set to avoid duplicates if a trending movie is in both Week and Day
            var idSet: Set<Int> = []
            // Get the movies from the 2 lists we support
            for movie in DataManager.shared.popularMovies {
                if let movieId = movie.id, idArr.contains(movieId) {
                    idSet.insert(movieId)
                    arr.append(movie)
                }
            }
            for movie in DataManager.shared.trendingMoviesWeek {
                if let movieId = movie.id, idArr.contains(movieId), !idSet.contains(movieId) {
                    idSet.insert(movieId)
                    arr.append(movie)
                }
            }
            for movie in DataManager.shared.trendingMoviesDay {
                if let movieId = movie.id, idArr.contains(movieId), !idSet.contains(movieId) {
                    arr.append(movie)
                }
            }
            organizeSet(arr: arr)
        }
    }
    
    private func organizeSet(arr: [MovieData]) {
        var favoritesArray: [MovieData] = arr
        favoritesArray.sort(by: {$0.movieName ?? "" < $1.movieName ?? "" })
        sortedMovies = favoritesArray
    }
}

extension FavoritesViewModel: FavoriteManager {
    func manageFavorite(id: Int, index: Int) {
        // No error handling here. The List will never fail to delete on swipe
        var favoritesArr = Set(favList)
        favoritesArr.remove(id)
        UserDefaults.standard.set(Array(favoritesArr), forKey: DataManager.favoritesKey)
        sortedMovies.remove(at: index)
    }
}
