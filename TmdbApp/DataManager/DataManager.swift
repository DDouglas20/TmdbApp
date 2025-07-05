//
//  DataManager.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation

class DataManager {
    
    // MARK: Static Properties
    static let shared = DataManager()
    
    static let favoritesKey = "favorites"
    
    // MARK: Properties
    
    let digitalType = 4 // Digital only releases like Amazon Prime / Netflix
    
    let theaterType = 3 // Theatrical releases
    
    let usCode = "US"
    
    var popularMovies = [MovieData]()
    
    var trendingMoviesDay = [MovieData]()
    
    var trendingMoviesWeek = [MovieData]()
    
    // Stop duplicates
    var popDict: [Int: Bool] = [:]
    var trendDayDict: [Int: Bool] = [:]
    var trendWeekDict: [Int: Bool] = [:]
    
    var genreMap = [Int: String]()
    
    func initMoviesArr(model: MovieModel, dataState: DataState) {
        
        switch dataState {
        case .popular:
            for movie in model.results {
                DataManager.shared.popularMovies.append(
                    .init(
                        id: movie.id,
                        isAdult: movie.adult,
                        movieName: movie.original_title,
                        movieRating: movie.vote_average,
                        reviewCount: movie.vote_count,
                        releaseDate: movie.release_date,
                        overview: movie.overview,
                        genreIds: movie.genre_ids,
                        portaitPath: movie.poster_path,
                        landscapePath: movie.backdrop_path
                    )
                )
            }
        case .trendWeek:
            for movie in model.results {
                DataManager.shared.trendingMoviesWeek.append(
                    .init(
                        id: movie.id,
                        isAdult: movie.adult,
                        movieName: movie.original_title,
                        movieRating: movie.vote_average,
                        reviewCount: movie.vote_count,
                        releaseDate: movie.release_date,
                        overview: movie.overview,
                        genreIds: movie.genre_ids,
                        portaitPath: movie.poster_path,
                        landscapePath: movie.backdrop_path
                    )
                )
            }
        case .trendDay:
            for movie in model.results {
                DataManager.shared.trendingMoviesDay.append(
                    .init(
                        id: movie.id,
                        isAdult: movie.adult,
                        movieName: movie.original_title,
                        movieRating: movie.vote_average,
                        reviewCount: movie.vote_count,
                        releaseDate: movie.release_date,
                        overview: movie.overview,
                        genreIds: movie.genre_ids,
                        portaitPath: movie.poster_path,
                        landscapePath: movie.backdrop_path
                    )
                )
            }
        }
    }
    
    func addVideoData(for id: Int, key: String?, arr: inout [MovieData]) {
        guard let key, let index = arr.firstIndex(where: { $0.id == id}) else {
            print("Could not match id with key")
            return
        }
        arr[index].youtubeId = key
    }
    
    func addMovieDetailsData(for id: Int, details: MovieDetails, arr: inout [MovieData]) {
        guard let index = arr.firstIndex(where: { $0.id == id}) else {
            print("Could not match id with key")
            return
        }
        arr[index].budget = details.budget
        arr[index].revenue = details.revenue
        arr[index].runtime = details.runtime
        arr[index].productionCompanies = details.productionCompanies
    }
    
    func addCertDetails(for id: Int, details: [ReleaseResults]?, arr: inout [MovieData]) {
        guard let details, let movieIndex = arr.firstIndex(where: { $0.id == id}) else { return }
        if let index = details.firstIndex(where: { $0.country == usCode }),
           let releaseResults = details[index].releaseDates,
           let mainReleaseIndex = releaseResults.firstIndex(where: { ($0.type == theaterType) || ($0.type == digitalType)})
        {
            arr[movieIndex].certification = releaseResults[mainReleaseIndex].certification
        }
    }
    
    func addGenreDetails(arr: inout [MovieData]) {
        for index in arr.indices {
            guard let genreIds = arr[index].genreIds else {
                continue
            }

            var categoryList: [String] = []
            for genreId in genreIds {
                if let genreName = genreMap[genreId] {
                    categoryList.append(genreName)
                }
            }

            arr[index].categories = categoryList
        }
    }
    
    func addDirectorData(for id: Int, data: CrewModel, arr: inout [MovieData]) {
        guard let index = arr.firstIndex(where: { $0.id == id}) else {
            print("Could not match id with key")
            return
        }
        var director: String?
        // First find director
        if let crew = data.crew {
            for member in crew {
                if member.job?.lowercased() == "director" {
                    director = member.name?.lowercased()
                    arr[index].director = .init(id: member.id ?? -1, name: director ?? "Unknown", jobs: []) // We should never hit unknown cause we verify it exists
                }
            }
            // Second find all the roles the director was apart of
            if let director {
                var jobs: [String] = []
                for member in crew {
                    if member.name?.lowercased() == director, let job = member.job {
                        jobs.append(job)
                    }
                }
                arr[index].director?.jobs = jobs
            }
        }
    }
    
    func modifyMovieArray(dataState: DataState, operation: (inout [MovieData]) -> Void) {
        switch dataState {
        case .popular:
            operation(&popularMovies)
        case .trendWeek:
            operation(&trendingMoviesWeek)
        case .trendDay:
            operation(&trendingMoviesDay)
        }
    }
    
    func checkDictForValue(for id: Int?) -> MovieData? {
        guard let id else { return nil }
        if popDict[id] == true {
            return popularMovies.first(where: { $0.id == id })
        } else if trendWeekDict[id] == true {
            return trendingMoviesWeek.first(where: { $0.id == id })
        } else if trendDayDict[id] == true {
            return trendingMoviesDay.first(where: { $0.id == id })
        }
        return nil
    }
    
    enum DataState {
        case popular
        case trendWeek
        case trendDay
    }
}
