//
//  MoviesList.swift
//  movie-db-2
//
//  Created by Tina Andria on 20/04/2021.
//

import Foundation

struct Movie {
    let title: String
    let adult: Bool
    let posterUrl: URL?
    let overview: String
    let releaseDate: String
    var genres: [Int: String]
    let originalTitle: String
    let originalLanguage: String
    let popularity: Float
    let voteCount: Int
    let voteAverage: Float
    let identifier: Int

    init(representation: MovieDetailRepresentation, genres: [Int: String], configuration: Configuration) {
        self.title = representation.title
        self.adult = representation.adult
        self.overview = representation.overview
        self.releaseDate = representation.releaseDate
        self.originalTitle = representation.originalTitle
        self.originalLanguage = representation.originalLanguage
        self.popularity = representation.popularity
        self.voteCount = representation.voteCount
        self.voteAverage = representation.voteAverage
        self.identifier = representation.id

        // Setup poster Url
        if let posterPath = representation.posterPath, let url = URL(string: configuration.secureBaseUrl + configuration.posterSize[3] + posterPath
           ) {
            print(url)
            self.posterUrl = url
        } else {
            self.posterUrl = nil
        }


        // Setup genres
        self.genres = [:]

        for genreId in representation.genreIds {
            if let genreName = genres[genreId] {
                self.genres.updateValue(genreName, forKey: genreId)
            }
        }
    }
}
