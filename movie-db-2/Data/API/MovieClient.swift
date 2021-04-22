//
//  RemoteDataStore.swift
//  movie-db-2
//
//  Created by Tina Andria on 19/04/2021.
//

import Foundation
import Alamofire
import Combine

class MovieClient {

    let apiKey = tmdbApiKey
    let baseURL = "https://api.themoviedb.org/3"

    // Json decoder
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }

    // MARK: - Function

    func fetchConfiguration(configCompletionHandler: @escaping (Result<ConfigurationRepresentation, TmdbApiError>) -> Void) {
        let endpointPath = UrlPath.config(apiKey: apiKey)

        guard let url = URL(string: baseURL + endpointPath.pathComponent) else { return }

        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: ConfigurationRepresentation.self,
                                  decoder: decoder,
                                  completionHandler: { (response) in
                                    switch response.result {
                                    case .failure:
                                        switch response.response?.statusCode {
                                        case 401:
                                            configCompletionHandler(.failure(.wrongApiKey))
                                        case 404:
                                            configCompletionHandler(.failure(.notFound))
                                        default:
                                            break
                                        }
                                    case .success(let config):
                                        configCompletionHandler(.success(config))
                                    }
                                  }
            )
    }

    func fetchMoviesbyTrend(page: Int) -> AnyPublisher<MoviesRepresentation, TmdbApiError> {

        let endpointPath = UrlPath.movies(mediatType: "movie",
                                          timeWindow: "day",
                                          apiKey: apiKey,
                                          page: page)

        return Future<MoviesRepresentation, TmdbApiError> { promise in
            guard let url = URL(string: self.baseURL + endpointPath.pathComponent) else {
                return promise(.failure(.networkError))
            }

            AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: MoviesRepresentation.self,
                                   decoder: self.decoder,
                                      completionHandler: { (response) in
                                        switch response.result {
                                        case .failure:
                                            switch response.response?.statusCode {
                                            case 401:
                                                return promise(.failure(.wrongApiKey))
                                            case 404:
                                                return promise(.failure(.notFound))
                                            default:
                                                break
                                            }
                                        case .success(let movies):
                                            return promise(.success(movies))
                                        }
                                      }
                )
        }.eraseToAnyPublisher()
    }

    func getMoviesGenres(genresCompletionHandler: @escaping (Result<GenresListRepresentation, TmdbApiError>) -> Void) {
        let endpointPath = UrlPath.genre(apiKey: apiKey)
        guard let url = URL(string: baseURL + endpointPath.pathComponent) else { return }

        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: GenresListRepresentation.self,
                               decoder: decoder,
                                  completionHandler: { (response) in
                                    switch response.result {
                                    case .failure:
                                        switch response.response?.statusCode {
                                        case 401:
                                            genresCompletionHandler(.failure(.wrongApiKey))
                                        case 404:
                                            genresCompletionHandler(.failure(.notFound))
                                        default:
                                            break
                                        }
                                    case .success(let genres):
                                        genresCompletionHandler(.success(genres))
                                    }
                                  }
            )
    }
}
