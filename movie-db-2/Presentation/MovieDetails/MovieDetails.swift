//
//  MovieDetails.swift
//  movie-db-2
//
//  Created by Tina Andria on 21/04/2021.
//

import Foundation
import UIKit

class MovieDetails: UIViewController {

    var titleText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = titleText

    }

    @IBOutlet weak var titleLabel: UILabel!
}
