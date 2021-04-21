//
//  UrlPath.swift
//  movie-db-2
//
//  Created by Tina Andria on 19/04/2021.
//

import Foundation

enum UrlPath {
    case movies(mediatType: String, timeWindow: String, apiKey: String, page: Int)
    case detail(movieId: Int, apiKey: String)
    case genre(apiKey: String)
    case config(apiKey: String)

    var pathComponent: String {
        switch self {
        case .movies(let mediaType, let timeWindow, let apiKey, let page):
            return "/trending/\(mediaType)/\(timeWindow)?api_key=\(apiKey)&language=fr-FR&page=\(page)"
        case .detail(let movieId, let apiKey):
            return "/movie/\(movieId)?api_key=\(apiKey)&language=fr-FR"
        case .genre(let apiKey):
            return "/genre/movie/list?api_key=\(apiKey)&language=fr-FR"
        case .config(let apiKey):
            return "/configuration?api_key=\(apiKey)"
        }
    }
}
