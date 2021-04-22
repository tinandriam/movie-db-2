//
//  MovieDetails.swift
//  movie-db-2
//
//  Created by Tina Andria on 21/04/2021.
//

import Foundation
import SDWebImage
import UIKit

class MovieDetails: UIViewController {

    // MARK: - Parameter

    var movie: Movie?

    // MARK: - UIParameters

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieReleaseDate: UILabel!
    @IBOutlet weak var movieGenresLabel: UILabel!
    @IBOutlet weak var adultMarker: UIImageView!
    @IBOutlet weak var movieOverview: UILabel!

    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let movie = movie {
            movieTitleLabel.text = movie.title
            moviePosterImageView.sd_setImage(with: movie.posterUrl,
                                            placeholderImage: UIImage(named: "PosterPlaceholder"))
            movieReleaseDate.text = "Date de sortie: " + movie.releaseDate
            movieGenresLabel.text = "Genres: " + Array(movie.genres.values).joined(separator: ", ")
            adultMarker.image = UIImage(named: "AdultMarker")
            adultMarker.isHidden = !movie.adult
            movieOverview.text = "Synopsis: " + movie.overview
        }

    }
}
