//
//  MoviesViewModel.swift
//  movie-db-2
//
//  Created by Tina Andria on 20/04/2021.
//

import Foundation
import Combine

protocol MoviesViewModelDelegate {
    func onFetchSuccess(_ newIndexPathsToReload: [IndexPath]?)
}

class MoviesViewModel {

    // MARK: - Parameters

    let client = MovieClient()
    let movieRepository = MovieRepository()

    var movies = CurrentValueSubject<[Movie]?, TmdbApiError>([])
    var genresRepresentation = CurrentValueSubject<GenresListRepresentation?, Never>(nil)
    var configuration = CurrentValueSubject<ConfigurationRepresentation?, Never>(nil)

    var isFetchInProgress: Bool = false
    var currentPage: Int = 1
    var totalMovies: Int = 0

    var delegate: MoviesViewModelDelegate? = nil

    var bag: Set<AnyCancellable> = []

    // MARK: - Functions

    func setupMovies(configuration: ConfigurationRepresentation, errorCompletionHandler: @escaping ((TmdbApiError) -> Void)) {

        if genresRepresentation.value == nil {
            setupGenres(errorCompletinHandler: { error in
                errorCompletionHandler(error)
            })
        }

        genresRepresentation.sink(receiveValue: { genres in
            if let genres = genres {
                self.fetchMovies(genres: genres, config: configuration)
            }
        }).store(in: &bag)
    }

    func setupGenres(errorCompletinHandler: @escaping (TmdbApiError) -> Void) {
        client.getMoviesGenres(genresCompletionHandler: { result in
            switch result {
            case .failure(let error):
                errorCompletinHandler(error)
            case .success(let genresRepresentation):
                self.genresRepresentation.value = genresRepresentation
            }
        })
    }

    func setupConfiguration(errorCompletionHandler: @escaping (TmdbApiError) -> Void) {
        client.fetchConfiguration(configCompletionHandler: { result in
            switch result {
            case .failure(let error):
                errorCompletionHandler(error)
            case .success(let configurationRepresentation):
                self.setupMovies(configuration: configurationRepresentation, errorCompletionHandler: errorCompletionHandler)
                self.configuration.value = configurationRepresentation
            }
        })
    }

    func fetchMovies(genres: GenresListRepresentation, config: ConfigurationRepresentation) -> AnyPublisher<[Movie], TmdbApiError> {

        return Future<[Movie], TmdbApiError> { promise in
            guard self.isFetchInProgress == false else {
                promise(.failure(TmdbApiError.processOnGoing))
                return
            }

            self.isFetchInProgress = true

            self.client.fetchMoviesbyTrend(page: self.currentPage)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .networkError:
                            promise(.failure(.networkError))
                        case .notFound:
                            promise(.failure(.notFound))
                        case .wrongApiKey:
                            promise(.failure(.wrongApiKey))
                        default:
                            break
                        }
                        self.isFetchInProgress = false
                    case .finished:
                        self.isFetchInProgress = false
                    }
                }, receiveValue: { moviesRepresentation in
                    let newMovies = self.movieRepository.setupMovies(moviesRepresentation: moviesRepresentation, genresRepresentation: genres, configuration: config)
                    self.movies.value?.append(contentsOf: newMovies)
                    self.currentPage += 1
                    self.isFetchInProgress = false
                    self.totalMovies = moviesRepresentation.totalResults

                    if moviesRepresentation.page > 1 {
                        let indexPathsToReload = self.computeIndexPathsToReload(from: newMovies)
                        self.delegate?.onFetchSuccess(indexPathsToReload)
                    } else {
                        self.delegate?.onFetchSuccess(.none)
                    }
                }).store(in: &self.bag)
        }.eraseToAnyPublisher()

    }

    func computeIndexPathsToReload(from newMovies: [Movie]) -> [IndexPath] {
        guard let movies = movies.value else {
            return []
        }

        let startIndex = movies.count - newMovies.count
        let endIndex = startIndex + newMovies.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
