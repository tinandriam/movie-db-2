//
//  MovieCell.swift
//  movie-db-2
//
//  Created by Tina Andria on 21/04/2021.
//

import Foundation
import UIKit

class MovieCell: UITableViewCell {

    // MARK: - UIParameters

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var adultContentMarker: UIImageView!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var voteAverageLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
}
