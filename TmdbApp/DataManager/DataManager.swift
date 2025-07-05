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
    
    var genreMap = [Int: String]()
    
    func addVideoData(for id: Int, key: String?) {
        guard let key, let index = popularMovies.firstIndex(where: { $0.id == id}) else {
            print("Could not match id with key")
            return
        }
        popularMovies[index].youtubeId = key
    }
    
    func addMovieDetailsData(for id: Int, details: MovieDetails) {
        guard let index = popularMovies.firstIndex(where: { $0.id == id}) else {
            print("Could not match id with key")
            return
        }
        popularMovies[index].budget = details.budget
        popularMovies[index].revenue = details.revenue
        popularMovies[index].runtime = details.runtime
        popularMovies[index].productionCompanies = details.productionCompanies
    }
    
    func addCertDetails(for id: Int, details: [ReleaseResults]?, dataState: DataState) {
        guard let details, let movieIndex = popularMovies.firstIndex(where: { $0.id == id}) else { return }
        if let index = details.firstIndex(where: { $0.country == usCode }),
           let releaseResults = details[index].releaseDates,
           let mainReleaseIndex = releaseResults.firstIndex(where: { ($0.type == theaterType) || ($0.type == digitalType)})
        {
            dataState == .popular ? (popularMovies[movieIndex].certification = releaseResults[mainReleaseIndex].certification) : ()
        }
    }
    
    func addGenreDetails() {
        for index in popularMovies.indices {
            guard let genreIds = popularMovies[index].genreIds else {
                continue
            }

            var categoryList: [String] = []
            for genreId in genreIds {
                if let genreName = genreMap[genreId] {
                    categoryList.append(genreName)
                }
            }

            popularMovies[index].categories = categoryList
        }
    }
    
    func addDirectorData(for id: Int, data: CrewModel) {
        guard let index = popularMovies.firstIndex(where: { $0.id == id}) else {
            print("Could not match id with key")
            return
        }
        var director: String?
        // First find director
        if let crew = data.crew {
            for member in crew {
                if member.job?.lowercased() == "director" {
                    director = member.name?.lowercased()
                    popularMovies[index].director = .init(id: member.id ?? -1, name: director ?? "Unknown", jobs: []) // We should never hit unknown cause we verify it exists
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
                popularMovies[index].director?.jobs = jobs
            }
        }
    }
    
    enum DataState {
        case popular
        case trending
    }
}
