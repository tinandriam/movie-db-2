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

class MoviesViewController: UITableViewController, MoviesViewModelDelegate {

    // MARK: - Parameters

    let viewModel: MoviesViewModel
    var bag: Set<AnyCancellable> = []

    // MARK: - Initializers

    init(viewModel: MoviesViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
        self.tableView.dataSource = self;
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tableView.prefetchDataSource = self

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
        return viewModel.totalMovies
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "MovieCell",
            for: indexPath
        ) as? MovieCell {
            if isLoadingCell(for: indexPath) {
                cell.loadingIndicator.isHidden = false
                cell.loadingIndicator.startAnimating()

                cell.adultContentMarker.isHidden = true
                cell.titleLabel.isHidden = true
                cell.overviewLabel.isHidden = true
                cell.voteAverageLabel.isHidden = true
                cell.posterImage.isHidden = true
            } else {
                if let movie = viewModel.movies.value?[indexPath.row] {
                    cell.loadingIndicator.isHidden = true
                    cell.titleLabel.text = movie.title
                    cell.overviewLabel.text = movie.overview
                    cell.voteAverageLabel.text = String(movie.popularity)
                    cell.adultContentMarker.image = UIImage(named: "AdultMarker")
                    cell.adultContentMarker.isHidden = !movie.adult
                    cell.posterImage.sd_setImage(with: movie.posterUrl,
                                                 placeholderImage: UIImage(named: "PosterPlaceholder"))
                }
            }
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if !isLoadingCell(for: indexPath) {
            guard let movie = viewModel.movies.value?[indexPath.row] else {
                return
            }
            let viewController = MovieDetails()
            viewController.titleText = movie.title
            modalPresentationStyle = .pageSheet

            present(viewController, animated: true, completion: nil)
        }
    }

    func onFetchSuccess(_ newIndexPathsToReload: [IndexPath]?) {
      guard let newIndexPathsToReload = newIndexPathsToReload else {
        tableView.isHidden = false
        tableView.reloadData()
        return
      }
      let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
      tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
}

extension MoviesViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            if let genres = viewModel.genresRepresentation.value, let configuration = viewModel.configuration.value {
                viewModel.fetchMovies(genres: genres, config: configuration)
            }
        }
    }


}

private extension MoviesViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        print(indexPath)
        return indexPath.row >= viewModel.movies.value?.count ?? 0
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}
