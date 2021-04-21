//
//  ConfigurationRepresentation.swift
//  movie-db-2
//
//  Created by Tina Andria on 21/04/2021.
//

import Foundation

struct ConfigurationRepresentation: Codable {
    let images: ImageConfigurationRepresentation
}

struct ImageConfigurationRepresentation: Codable {
    let baseUrl: String
    let secureBaseUrl: String
    let posterSizes: [String]
}
