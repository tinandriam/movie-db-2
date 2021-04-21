//
//  MoviesTableViewController.swift
//  movie-db-2
//
//  Created by Tina Andria on 20/04/2021.
//

import Foundation
import SDWebImage
import Combine
import UIKit

class MoviesViewController: UITableViewController {

    // MARK: - Parameters

    let viewModel: MoviesViewModel
    var bag: Set<AnyCancellable> = []

    // MARK: - Initializers

    init(viewModel: MoviesViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
        self.tableView.dataSource = self;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        viewModel.setupConfiguration()

        viewModel.movies
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { movies in
//                print(movies)
                self.tableView.reloadData()
            }).store(in: &bag)

        setupUI()

        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.registerMovieCell()
    }

    // MARK: - Functions

    func setupUI() {
        self.tableView.rowHeight = 200
    }


    // MARK: - UITableViewController

    func registerMovieCell() {
        let movieCell = UINib(nibName: "MovieCell", bundle: nil)

        self.tableView.register(movieCell, forCellReuseIdentifier: "MovieCell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.value?.count ?? 1 - 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let movie = viewModel.movies.value?[indexPath.row] else {
            return UITableViewCell()
        }

        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "MovieCell",
            for: indexPath
        ) as? MovieCell {
            cell.titleLabel.text = movie.title
            cell.overviewLabel.text = movie.overview
            cell.voteAverageLabel.text = String(movie.popularity)
            cell.adultContentMarker.image = UIImage(named: "AdultMarker")
            cell.adultContentMarker.isHidden = !movie.adult
            cell.posterImage.sd_setImage(with: movie.posterUrl,
                                         placeholderImage: UIImage(named: "PosterPlaceholder"))

            // missing images
            return cell
        }
        return UITableViewCell()
    }
}
