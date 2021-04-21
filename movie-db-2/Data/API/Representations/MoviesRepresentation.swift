//
//  MoviesRepresentation.swift
//  movie-db-2
//
//  Created by Tina Andria on 20/04/2021.
//

import Foundation

struct MoviesRepresentation: Codable {
    let page: Int
    let results: [MovieDetailRepresentation]
    let totalPages: Int
    let totalResults: Int
}

struct MovieDetailRepresentation: Codable {
    let posterPath: String?
    let adult: Bool
    let overview: String
    let releaseDate: String
    let genreIds: [Int]
    let id: Int
    let originalTitle: String
    let originalLanguage: String
    let title: String
    let popularity: Float
    let voteCount: Int
    let voteAverage: Float
}
