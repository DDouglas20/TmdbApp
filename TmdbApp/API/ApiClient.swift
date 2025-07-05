//
//  ApiClient.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation


class ApiClient {
    
    // MARK: Static Properties
    static let shared = ApiClient()
    
    static let baseImageURL = "https://image.tmdb.org/t/p/w500"
    
    // MARK: Properties
    private struct Constants {
        static let baseURL = "https://api.themoviedb.org/3/"
        static let apiKey = "ffc59b7cf2895c4d60f4d00a7d1bbd53" // TODO: Remove api key before push
    }
    
    // MARK: Functions
    
    func loadPopularMovies() async {
        do {
            let popular = try await withCheckedThrowingContinuation { continuation in
                getPopularMovies { success in
                    if success {
                        continuation.resume(returning: DataManager.shared.popularMovies)
                        for movie in DataManager.shared.popularMovies {
                            if let id = movie.id {
                                DataManager.shared.popDict[id] = true
                            }
                        }
                    } else {
                        continuation.resume(throwing: APIError.unknown)
                    }
                }
            }
            
            let trendingWeek = try await withCheckedThrowingContinuation { continuation in
                getTrendingMoviesWeek { success in
                    if success {
                        continuation.resume(returning: DataManager.shared.trendingMoviesWeek)
                        for movie in DataManager.shared.trendingMoviesWeek {
                            if let id = movie.id {
                                DataManager.shared.trendWeekDict[id] = true
                            }
                        }
                    } else {
                        continuation.resume(throwing: APIError.unknown)
                    }
                }
            }
            
            let trendingDay = try await withCheckedThrowingContinuation { continuation in
                getTrendingMoviesDay { success in
                    if success {
                        continuation.resume(returning: DataManager.shared.trendingMoviesDay)
                        for movie in DataManager.shared.trendingMoviesDay {
                            if let id = movie.id {
                                DataManager.shared.trendDayDict[id] = true
                            }
                        }
                    } else {
                        continuation.resume(throwing: APIError.unknown)
                    }
                }
            }

            await withTaskGroup(of: Void.self) { group in
                for index in popular.indices {
                    group.addTask {
                        let movie = popular[index]
                        do {
                            try await self.getVideoData(movieId: movie.id ?? 0, dataState: .popular)
                            try await self.getMovieDetails(movieId: movie.id ?? 0, dataState: .popular)
                            try await self.getCredits(movieId: movie.id ?? 0, dataState: .popular)
                            try await self.fetchGenres(dataState: .popular)
                            try await self.getMovieCertification(movieId: movie.id ?? 0, dataState: .popular)
                            
                        } catch {
                            print("Failed to get movie \(movie.id ?? -1): \(error)")
                        }
                    }
                }
                for index in trendingWeek.indices {
                    group.addTask {
                        let movie = trendingWeek[index]
                        do {
                            try await self.getVideoData(movieId: movie.id ?? 0, dataState: .trendWeek)
                            try await self.getMovieDetails(movieId: movie.id ?? 0, dataState: .trendWeek)
                            try await self.getCredits(movieId: movie.id ?? 0, dataState: .trendWeek)
                            try await self.fetchGenres(dataState: .trendWeek)
                            try await self.getMovieCertification(movieId: movie.id ?? 0, dataState: .trendWeek)
                            
                        } catch {
                            print("Failed to get movie \(movie.id ?? -1): \(error)")
                        }
                    }
                }
                for index in trendingDay.indices {
                    group.addTask {
                        let movie = trendingDay[index]
                        do {
                            try await self.getVideoData(movieId: movie.id ?? 0, dataState: .trendDay)
                            try await self.getMovieDetails(movieId: movie.id ?? 0, dataState: .trendDay)
                            try await self.getCredits(movieId: movie.id ?? 0, dataState: .trendDay)
                            try await self.fetchGenres(dataState: .trendDay)
                            try await self.getMovieCertification(movieId: movie.id ?? 0, dataState: .trendDay)
                            
                        } catch {
                            print("Failed to get movie \(movie.id ?? -1): \(error)")
                        }
                    }
                }
            }

            print("Finished getting all movies")
            print("Week count: \(DataManager.shared.trendingMoviesWeek.count)\nDay count: \(DataManager.shared.trendingMoviesDay.count)")

        } catch {
            print("Error during initial movie load: \(error)")
        }
    }

    
    /// Gets the details for an individual movie
    /// - Parameter movieId: The movie's id
    private func getMovieDetails(movieId: Int, dataState: DataManager.DataState) async throws {
        if dataInCache(movieId: movieId, dataState: dataState) {
            return
        }
        guard let url = formURL(baseUrl: Constants.baseURL + "movie/\(movieId)", endpoint: nil) else {
            throw APIError.invalidURL
        }

        return try await withCheckedThrowingContinuation { continuation in
            request(url: url, expecting: MovieDetails.self) { result in
                switch result {
                case .success(let details):
                    DataManager.shared.modifyMovieArray(dataState: dataState, operation: { arr in
                        DataManager.shared.addMovieDetailsData(for: movieId, details: details, arr: &arr)
                    })
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func getMovieCertification(movieId: Int, dataState: DataManager.DataState) async throws {
        if dataInCache(movieId: movieId, dataState: dataState) {
            return
        }
        guard let url = formURL(baseUrl: Constants.baseURL + "movie/\(movieId)/", endpoint: .cert) else {
            throw APIError.invalidURL
        }

        return try await withCheckedThrowingContinuation { continuation in
            request(url: url, expecting: ReleaseDatesModel.self) { result in
                switch result {
                case .success(let details):
                    DataManager.shared.modifyMovieArray(dataState: dataState, operation: { arr in
                        DataManager.shared.addCertDetails(for: movieId, details: details.results, arr: &arr)
                    })
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    
    /// Gets the youtubeId for watching the trailer
    /// - Parameter movieId: The movie's id
    private func getVideoData(movieId: Int, dataState: DataManager.DataState) async throws {
        if dataInCache(movieId: movieId, dataState: dataState) {
            return
        }
        guard let url = formURL(baseUrl: Constants.baseURL + "movie/\(movieId)/", endpoint: .videos) else {
            throw APIError.invalidURL
        }
        return try await withCheckedThrowingContinuation { continuation in
            request(url: url, expecting: VideoModel.self, completion: { result in
                switch result {
                case .success(let response):
                    continuation.resume()
                    if let filteredArray = response.results?.filter({ $0.site?.lowercased() == "youtube" && $0.type?.lowercased() == "trailer"}),
                       let trailer = filteredArray.first {
                        DataManager.shared.modifyMovieArray(dataState: dataState, operation: { arr in
                            DataManager.shared.addVideoData(for: movieId, key: trailer.key, arr: &arr)
                        })
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }
    
    // TODO: Genre call
    func fetchGenres(dataState: DataManager.DataState) async throws {
        guard let url = formURL(baseUrl: Constants.baseURL + "genre/movie/", endpoint: .list) else {
            throw APIError.invalidURL
        }

        _ = try await withCheckedThrowingContinuation { continuation in
            request(url: url, expecting: ListModel.self) { result in
                switch result {
                case .success(_):
                    continuation.resume()
                    DataManager.shared.modifyMovieArray(dataState: dataState, operation: {arr in
                        DataManager.shared.addGenreDetails(arr: &arr)
                    })
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    
    /// Get movie credits so we can find the director
    /// - Parameter movieId: The movie's id
    private func getCredits(movieId: Int, dataState: DataManager.DataState) async throws {
        if dataInCache(movieId: movieId, dataState: dataState) {
            return
        }
        guard let url = formURL(baseUrl: Constants.baseURL + "movie/\(movieId)/", endpoint: .credits) else {
            throw APIError.invalidURL
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            request(url: url, expecting: CrewModel.self) { result in
                switch result {
                case .success(let response):
                    // Example: find the director from crew
                    if (response.crew?.first(where: { $0.job == "Director" })) != nil {
                        DataManager.shared.modifyMovieArray(dataState: dataState, operation: { arr in
                            DataManager.shared.addDirectorData(for: movieId, data: response, arr: &arr)
                        })
                    }
                    continuation.resume() // success
                case .failure(let error):
                    continuation.resume(throwing: error) // failure
                }
            }
        }
    }
    
    /// Gets the popular movies list from the api
    /// - Parameter completion: Completion on whether or not the api call succeeded
    func getPopularMovies(completion: @escaping (Bool) -> Void) {
        guard let url = formURL(baseUrl: Constants.baseURL, endpoint: Endpoint.popular) else {
            // Invalid url
            print(APIError.invalidURL)
            completion(false)
            return
        }
        
        request(url: url, expecting: MovieModel.self) { result in
            switch result {
            case .success(let response):
                DataManager.shared.initMoviesArr(model: response, dataState: .popular)
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        }
    }
    
    
    /// Gets the trending movies for the week
    /// - Parameter completion: Completion on whether or not the api call succeeded
    func getTrendingMoviesWeek(completion: @escaping (Bool) -> Void) {
        guard let url = formURL(baseUrl: Constants.baseURL, endpoint: Endpoint.trendWeek) else {
            // Invalid url
            print(APIError.invalidURL)
            completion(false)
            return
        }
        request(url: url, expecting: MovieModel.self) { result in
            switch result {
            case .success(let response):
                DataManager.shared.initMoviesArr(model: response, dataState: .trendWeek)
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        }
    }
    
    /// Gets the trending movies for the day
    /// - Parameter completion: Completion on whether or not the api call succeeded
    func getTrendingMoviesDay(completion: @escaping (Bool) -> Void) {
        guard let url = formURL(baseUrl: Constants.baseURL, endpoint: Endpoint.trendDay) else {
            // Invalid url
            print(APIError.invalidURL)
            completion(false)
            return
        }
        request(url: url, expecting: MovieModel.self) { result in
            switch result {
            case .success(let response):
                DataManager.shared.initMoviesArr(model: response, dataState: .trendDay)
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        }
    }
    
    private func dataInCache(movieId: Int, dataState: DataManager.DataState) -> Bool {
//        if let movieData = DataManager.shared.checkDictForValue(for: movieId) {
//            switch dataState {
//            case .popular:
//                // Popular case we dont need to do anything
//                return false
//            case .trendWeek:
//                // Popular might have trending week movies
//                if let index = DataManager.shared.trendingMoviesWeek.firstIndex(where: { $0.id == movieData.id }) {
//                    DataManager.shared.trendingMoviesWeek[index] = movieData
//                }
//                return true
//            case .trendDay:
//                // Popular OR Trending week might have trending day movies
//                if let index = DataManager.shared.trendingMoviesDay.firstIndex(where: { $0.id == movieData.id }) {
//                    DataManager.shared.trendingMoviesDay[index] = movieData
//                }
//                return true
//            }
//        }
//        return false
        return false
    }
    
    // MARK: Boiler Plate Functions & Enums
    private func formURL(baseUrl: String, endpoint: Endpoint?, queryParams: [String: String] = [:]) -> URL? {
        var urlString = baseUrl
        if let endpoint {
            urlString += endpoint.rawValue
        }
        var queryItems = [URLQueryItem]()
        // Add params to request
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        // Add token
        queryItems.append(.init(name: "api_key", value: Constants.apiKey)) // TODO: Double check this is the param for token
        
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        
        return URL(string: urlString)
    }
    
    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url else {
            // Malformed url, return error
            completion(.failure(APIError.invalidURL))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data, error == nil else {
                if let error {
                    completion(.failure(error))
                    return
                }
                completion(.failure(APIError.noDataReturned))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private enum Endpoint: String {
        case configuration = "configuration"
        case popular = "movie/popular"
        case videos = "videos"
        case list = "list"
        case credits = "credits"
        case cert = "release_dates"
        case trendWeek = "trending/movie/week"
        case trendDay = "trending/movie/day"
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidURL
        case decodingFailed
        case unknown
    }
}


