//
//  Configuration.swift
//  movie-db-2
//
//  Created by Tina Andria on 21/04/2021.
//

import Foundation

struct Configuration {
    let baseUrl: String
    let secureBaseUrl: String
    let posterSize: [String]

    init(baseUrl: String, secureBaseUrl: String, posterSize: [String]) {
        self.baseUrl = baseUrl
        self.secureBaseUrl = secureBaseUrl
        self.posterSize = posterSize
    }
}
