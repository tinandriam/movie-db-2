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

        viewModel.setupConfiguration(errorCompletionHandler: { [weak self] error in
            self?.presentErrorAlert(errorType: error)
        })

        viewModel.movies
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.presentErrorAlert(errorType: error)
                }
            }, receiveValue: { [weak self] movies in
                self?.tableView.reloadData()
            }).store(in: &bag)

        setupUI()

        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.registerMovieCell()
    }

    // MARK: - Functions

    func setupUI() {
        self.tableView.rowHeight = 200
    }

    func presentErrorAlert(errorType: TmdbApiError) {
        var errorMessage: String
        switch errorType {
        case .networkError:
            errorMessage = "Oops, il semblerait que la connexion internet ne fonctionne plus. Veuillez réessayer."
        case .notFound:
            errorMessage = "Nous n'avons pas trouvé ce que vous recherchez."
        case .wrongApiKey, .processOnGoing, .error(_):
            errorMessage = "Erreur interne"
        }
        let understandButton = UIAlertAction(title: "J'ai compris", style: .cancel, handler: nil)
        let errorAlert = UIAlertController(title: "Erreur", message: errorMessage, preferredStyle: .alert)
        errorAlert.addAction(understandButton)
        self.present(errorAlert, animated: true, completion: nil)
    }

    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.movies.value?.count ?? 0
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
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
                cell.posterImage.isHidden = true
            } else {
                if let movie = viewModel.movies.value?[indexPath.row] {
                    cell.loadingIndicator.isHidden = true
                    cell.titleLabel.text = movie.title
                    cell.overviewLabel.text = movie.overview
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
            viewController.movie = movie
            modalPresentationStyle = .pageSheet

            present(viewController, animated: true, completion: nil)
        }
    }

    // MARK: - MoviesViewModelDelegate

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

    // MARK: - Extensions

extension MoviesViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            if let genres = viewModel.genresRepresentation.value, let configuration = viewModel.configuration.value {
                viewModel.fetchMovies(genres: genres, config: configuration)
            }
        }
    }


}
