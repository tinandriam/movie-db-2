//
//  TmdbApiErrorRepresentation.swift
//  movie-db-2
//
//  Created by Tina Andria on 20/04/2021.
//

import Foundation

enum TmdbApiError: Error {
    case notFound, wrongApiKey, networkError
}

struct TmdbApiErrorRepresentation: Codable {
    let statusMessage: String
    let statusCode: Int
}
