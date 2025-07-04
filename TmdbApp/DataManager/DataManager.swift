//
//  DataManager.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    var popularMovies = [MovieData]()
    
    var genreMap = [Int: String]()
    
    func addVideoData(for id: Int, key: String?) {
        guard let key, let index = popularMovies.firstIndex(where: { $0.id == id}) else {
            print("Could not match id with key")
            return
        }
        popularMovies[index].key = key
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
                    popularMovies[index].director = .init(name: director ?? "Unknown", jobs: []) // We should never hit unknown cause we verify it exists
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
    
}
