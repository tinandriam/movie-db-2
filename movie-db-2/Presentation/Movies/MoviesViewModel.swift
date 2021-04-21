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

    var movies = CurrentValueSubject<[Movie]?, Never>([])
    var genresRepresentation = CurrentValueSubject<GenresListRepresentation?, Never>(nil)
    let client = MovieClient()
    let movieRepository = MovieRepository()
    var configuration = CurrentValueSubject<ConfigurationRepresentation?, Never>(nil)

    var isFetchInProgress: Bool = false
    var currentPage: Int = 1
    var delegate: MoviesViewModelDelegate? = nil
    var totalMovies: Int = 0
    var bag: Set<AnyCancellable> = []

    // MARK: - Functions

    func setupMovies(configuration: ConfigurationRepresentation) {

        if genresRepresentation.value == nil {
            setupGenres()
        }

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
                self.configuration.value = configurationRepresentation
            }
        })
    }

    func fetchMovies(genres: GenresListRepresentation, config: ConfigurationRepresentation) {
        guard isFetchInProgress == false else {
            return
        }

        isFetchInProgress = true

        client.fetchMoviesbyTrend(page: currentPage)
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
                    let indexPathsToReload = self.calculateIndexPathsToReload(from: newMovies)
                    self.delegate?.onFetchSuccess(indexPathsToReload)
                  } else {
                    self.delegate?.onFetchSuccess(.none)
                  }
            }).store(in: &bag)

    }

    private func calculateIndexPathsToReload(from newMovies: [Movie]) -> [IndexPath] {
        guard let movies = movies.value else {
            return []
        }

        let startIndex = movies.count - newMovies.count
        let endIndex = startIndex + newMovies.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
