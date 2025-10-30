//
//  StarredGistsListVC.swift
//  GistsApp
//
//  Created by jvic on 29/08/24.
//

import Combine
import NetworkService
import UIKit

open class FavoritesListVC<T: FavoriteItem>: UITableViewController {
    private let viewModel: FavoritesListVM<T>
    private var cancellables = Set<AnyCancellable>()
    private let cellID = "FavoriteGistCell"

    lazy var noFavoritesLabel: UILabel = {
        let label = UILabel()
        label.text = "Nenhum favorito ainda"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .lightGray
        label.isHidden = true
        return label
    }()

    public init(viewModel: FavoritesListVM<T>) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.title
        tabBarItem.image = UIImage(systemName: "star.fill")
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: cellID)

        view.addSubview(noFavoritesLabel)
        remakeConstraints()
        setupBindings()
    }

    override open func viewWillAppear(_: Bool) {
        viewModel.connect()
    }

    func setupBindings() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }
                self.noFavoritesLabel.isHidden = items.count != 0
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    func remakeConstraints() {
        noFavoritesLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80)
        }
    }

    override open func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.items.count
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FavoriteCell
        let item = viewModel.items[indexPath.row]

        cell.fileCountLabel.text = item.favoriteSubtitle
        cell.titleLabel.text = item.favoriteTitle

        cell.setPlaceholder()
        Task { @MainActor in
            cell.avatarImageView.image = await viewModel.loadUserAvatar(item: item)
        }

        return cell
    }

    override open func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        80
    }

    override open func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelect(index: indexPath.row)
    }
}
