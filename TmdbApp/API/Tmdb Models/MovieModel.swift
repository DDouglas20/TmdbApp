//
//  TmdbModel.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation

struct MovieModel: Codable {
    var page: Int
    var results: [MovieResults]
    var totalPages: Int
    var totalResults: Int
    
    private enum CodingKeys: String, CodingKey {
        case page = "page"
        case results = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieResults: Codable {
    var adult: Bool
    var backdrop_path: String
    var genre_ids: [Int]
    var id: Int
    var original_language: String
    var original_title: String
    var overview: String
    var popularity: Double
    var poster_path: String
    var release_date: String
    var title: String
    var video: Bool
    var vote_average: Double
    var vote_count: Int

    enum CodingKeys: String, CodingKey {
        case adult
        case backdrop_path
        case genre_ids
        case id
        case original_language
        case original_title
        case overview
        case popularity
        case poster_path
        case release_date
        case title
        case video
        case vote_average
        case vote_count
    }

    init(from decoder: any Decoder, state: DataManager.DataState) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try values.decode(Int.self, forKey: .id)
        self.adult = try values.decode(Bool.self, forKey: .adult)
        self.backdrop_path = try values.decode(String.self, forKey: .backdrop_path)
        self.genre_ids = try values.decode([Int].self, forKey: .genre_ids)
        self.original_language = try values.decode(String.self, forKey: .original_language)
        self.original_title = try values.decode(String.self, forKey: .original_title)
        self.overview = try values.decode(String.self, forKey: .overview)
        self.popularity = try values.decode(Double.self, forKey: .popularity)
        self.poster_path = try values.decode(String.self, forKey: .poster_path)
        self.release_date = try values.decode(String.self, forKey: .release_date)
        self.title = try values.decode(String.self, forKey: .title)
        self.video = try values.decode(Bool.self, forKey: .video)
        self.vote_average = try values.decode(Double.self, forKey: .vote_average)
        self.vote_count = try values.decode(Int.self, forKey: .vote_count)
        
        // Dynamically append objects to data manager array as they are init
//        DataManager.shared.popularMovies.append(
//            .init(
//                id: self.id,
//                isAdult: self.adult,
//                movieName: self.original_title,
//                movieRating: self.vote_average,
//                reviewCount: self.vote_count,
//                releaseDate: self.release_date,
//                overview: self.overview,
//                genreIds: self.genre_ids,
//                portaitPath: self.poster_path,
//                landscapePath: self.backdrop_path
//            )
//        )
    }
}








enum Categories: String {
    case comedy = "Comedy"
    case drama = "Drama"
    case action = "Action"
    case romance = "Romance"
    case horror = "Horror"
    case sciFi = "Sci-Fi"
    case fantasy = "Fantasy"
    case mostPopular = "Most Popular"
}
