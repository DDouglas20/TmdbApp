//
//  ApiClient.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation


class ApiClient {
    
    static let shared = ApiClient()
    
    private struct Constants {
        static let baseURL = "https://api.themoviedb.org/3/"
        static let apiKey = "ffc59b7cf2895c4d60f4d00a7d1bbd53" // TODO: Remove api key before push
    }
    
    // TODO: Func retrieve image
    
    // Four api calls
    // 1. Video call
    // 2. Genre call
    // 3. Movie details call
    // 4. Credits call
    // Concurrency needed
    
    // TODO: Image call, Logo call (do it in one) - SCRAPPED KingFisher
    
    func loadPopularMovies(state: DataManager.DataState) async {
        do {
            let popular = try await withCheckedThrowingContinuation { continuation in
                getPopularMovies { success in
                    if success {
                        continuation.resume(returning: DataManager.shared.popularMovies)
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
                            try await self.getVideoData(movieId: movie.id ?? 0)
                            try await self.getMovieDetails(movieId: movie.id ?? 0)
                            try await self.getCredits(movieId: movie.id ?? 0)
                            try await self.fetchGenres()
                            try await self.getMovieCertification(movieId: movie.id ?? 0)
                            
                        } catch {
                            print("Failed to get movie \(movie.id ?? -1): \(error)")
                        }
                    }
                }
            }

            print("Finished getting all movies")

        } catch {
            print("Error during initial movie load: \(error)")
        }
    }

    
    /// Gets the details for an individual movie
    /// - Parameter movieId: The movie's id
    private func getMovieDetails(movieId: Int) async throws {
        guard let url = formURL(baseUrl: Constants.baseURL + "movie/\(movieId)", endpoint: nil) else {
            throw APIError.invalidURL
        }

        return try await withCheckedThrowingContinuation { continuation in
            request(url: url, expecting: MovieDetails.self) { result in
                switch result {
                case .success(let details):
                    DataManager.shared.addMovieDetailsData(for: movieId, details: details)
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func getMovieCertification(movieId: Int) async throws {
        guard let url = formURL(baseUrl: Constants.baseURL + "movie/\(movieId)/", endpoint: .cert) else {
            throw APIError.invalidURL
        }

        return try await withCheckedThrowingContinuation { continuation in
            request(url: url, expecting: ReleaseDatesModel.self) { result in
                switch result {
                case .success(let details):
                    DataManager.shared.addCertDetails(for: movieId, details: details.results, dataState: .popular)
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    
    /// Gets the youtubeId for watching the trailer
    /// - Parameter movieId: The movie's id
    private func getVideoData(movieId: Int) async throws {
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
                        DataManager.shared.addVideoData(for: movieId, key: trailer.key)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }
    
    // TODO: Genre call
    func fetchGenres() async throws {
        guard let url = formURL(baseUrl: Constants.baseURL + "genre/movie/", endpoint: .list) else {
            throw APIError.invalidURL
        }

        _ = try await withCheckedThrowingContinuation { continuation in
            request(url: url, expecting: ListModel.self) { result in
                switch result {
                case .success(_):
                    continuation.resume()
                    DataManager.shared.addGenreDetails()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // TODO: Credits call
    private func getCredits(movieId: Int) async throws {
        guard let url = formURL(baseUrl: Constants.baseURL + "movie/\(movieId)/", endpoint: .credits) else {
            throw APIError.invalidURL
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            request(url: url, expecting: CrewModel.self) { result in
                switch result {
                case .success(let response):
                    // Example: find the director from crew
                    if (response.crew?.first(where: { $0.job == "Director" })) != nil {
                        DataManager.shared.addDirectorData(for: movieId, data: response)
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
            return
        }
        
        request(url: url, expecting: PopularModel.self) { result in
            switch result {
            case .success(let model):
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        }
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
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidURL
        case decodingFailed
        case unknown
    }
}


