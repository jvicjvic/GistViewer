//
//  GistsListViewController.swift
//  GistsApp
//
//  Created by jvic on 28/08/24.
//

import Combine
import CoreNetwork
import UIKit

class GistsListVC: UITableViewController {
    let viewModel: GistsListVM
    private var cancellables = Set<AnyCancellable>()
    private let cellID = "GistCell"

    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        return indicator
    }()

    init(viewModel: GistsListVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        title = viewModel.title
        tabBarItem.image = UIImage(systemName: "note.text")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(GistCell.self, forCellReuseIdentifier: cellID)

        setupBindings()
        viewModel.connect()
    }

    override func viewWillAppear(_: Bool) {
        tableView.reloadData()
    }
}

// MARK: - Bindings

extension GistsListVC {
    func setupBindings() {
        // listagem da tableview
        viewModel.$gists
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        // tratamento de erro
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showAlertMessage(title: "Erro", message: message)
            }
            .store(in: &cancellables)

        // spinner de ocupado
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
    }
}

// MARK: - TableView

extension GistsListVC {
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.gists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! GistCell
        let gist = viewModel.gists[indexPath.row]

        cell.fileCountLabel.text = "\(gist.fileCount) arquivo(s)"
        cell.titleLabel.text = "\(gist.owner.login) / \(gist.filename)"

        cell.setPlaceholder()
        Task { @MainActor in
            cell.avatarImageView.image = await viewModel.loadAvatar(gist: gist)
        }
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        .spacing80
    }

    override func tableView(_: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.gists.count - 5 {
            viewModel.didReachEnd()
        }
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelect(index: indexPath.row)
    }
}
