//
//  ConfigurationRepository.swift
//  movie-db-2
//
//  Created by Tina Andria on 21/04/2021.
//

import Foundation

class ConfigurationRepository {

    func setupConfiguration(configurationRepresentation: ConfigurationRepresentation) -> Configuration {
        return Configuration(baseUrl: configurationRepresentation.images.baseUrl,
                                          secureBaseUrl: configurationRepresentation.images.secureBaseUrl,
                                          posterSize: configurationRepresentation.images.posterSizes)
    }
}
