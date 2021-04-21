//
//  GenresList.swift
//  movie-db-2
//
//  Created by Tina Andria on 20/04/2021.
//

import Foundation

struct Genre: Codable {
    let id: Int
    let name: String
}

struct GenresListRepresentation: Codable {
    let genres: [Genre]
}
