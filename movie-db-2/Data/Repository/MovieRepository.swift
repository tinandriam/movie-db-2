//
//  MovieRepository.swift
//  movie-db-2
//
//  Created by Tina Andria on 21/04/2021.
//

import Foundation

// image URL :
// baseURL/size/postser_path


class MovieRepository {

    

    func setupMovies(moviesRepresentation: MoviesRepresentation, genresRepresentation: GenresListRepresentation, configuration: ConfigurationRepresentation) -> [Movie] {

        let genres = Genres(representation: genresRepresentation).genres
        let configuration = Configuration(baseUrl: configuration.images.baseUrl,
                                          secureBaseUrl: configuration.images.secureBaseUrl,
                                          posterSize: configuration.images.posterSizes)
        var movies: [Movie] = []

        for movie in moviesRepresentation.results {
            movies.append(Movie(representation: movie, genres: genres, configuration: configuration))
        }
//        print(movies)
        return movies
    }
}
