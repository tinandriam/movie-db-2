//
//  MoviesViewModel.swift
//  movie-db-2
//
//  Created by Tina Andria on 20/04/2021.
//

import Foundation
import Combine

class MoviesViewModel {

    // MARK: - Parameters

    var movies = CurrentValueSubject<[Movie]?, Never>(nil)
    var genresRepresentation = CurrentValueSubject<GenresListRepresentation?, Never>(nil)
    let client = MovieClient()
    let movieRepository = MovieRepository()
    var configurations = CurrentValueSubject<ConfigurationRepresentation?, Never>(nil)
    var bag: Set<AnyCancellable> = []

    // MARK: - Initializer

    init() {}

    // MARK: - Functions

    func setupMovies(configuration: ConfigurationRepresentation) {
        setupGenres()

        genresRepresentation.sink(receiveValue: { genres in
            if let genres = genres {
                self.fetchMovies(genres: genres, config: configuration)
            }
        }).store(in: &bag)
        
    }

    func setupGenres() {
        client.getMoviesGenres(genresCompletionHandler: { result in
            switch result {
            case .failure:
                print("failure")
            case .success(let genresRepresentation):
                self.genresRepresentation.value = genresRepresentation
            }
        })
    }

    func setupConfiguration() {
        client.fetchConfiguration(configCompletionHandler: { result in
            switch result {
            case .failure:
                print("error")
            case .success(let configurationRepresentation):
                print(configurationRepresentation)
                self.setupMovies(configuration: configurationRepresentation)
//                self.configurations.value = configurationRepresentation
            }
        })
    }

    func fetchMovies(genres: GenresListRepresentation, config: ConfigurationRepresentation) {
        let page = 1

        client.fetchMoviesbyTrend(page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .networkError:
                        print("network error")
                    case .notFound:
                        print("not found")
                    case .wrongApiKey:
                        print("wring api key")
                    }
                case .finished:
                    break
                }
            }, receiveValue: { moviesRepresentation in
                self.movies.value = self.movieRepository.setupMovies(moviesRepresentation: moviesRepresentation, genresRepresentation: genres, configuration: config)
//                print(self.movies.value)
            }).store(in: &bag)

    }
}
