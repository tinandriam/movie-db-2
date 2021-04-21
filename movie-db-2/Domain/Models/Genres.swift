//
//  Genres.swift
//  movie-db-2
//
//  Created by Tina Andria on 20/04/2021.
//

import Foundation

class Genres {
    let genres: [Int: String]

    init(representation: GenresListRepresentation) {
        var genresDict: [Int:String] = [:]

        for genre in representation.genres {
            genresDict.updateValue(genre.name, forKey: genre.id)
        }
        self.genres = genresDict
    }
}
