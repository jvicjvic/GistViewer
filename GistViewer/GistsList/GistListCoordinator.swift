//
//  GistListCoordinator.swift
//  GistsApp
//
//  Created by jvic on 30/08/24.
//

import Combine
import Core
import Foundation
import UIKit

/// Navegação da listagem e exibição de detalhe dos Gists
class GistListCoordinator: CoreNavigatorCoordinator {
    var rootViewController: UINavigationController
    var childCoordinators = [CoreCoordinator]()
    var cancellables = Set<AnyCancellable>()

    init() {
        rootViewController = UINavigationController()
    }

    @MainActor lazy var listViewModel: GistsListVM = {
        let viewModel = GistsListVM()
        // apresenta detalhe
        viewModel.$selectedItem
            .compactMap { $0 }
            .sink { [weak self] gist in
                self?.presentDetail(gist: gist)
            }
            .store(in: &cancellables)

        return viewModel
    }()

    func start() {
        let listVC = GistsListVC(viewModel: listViewModel)
        rootViewController.setViewControllers([listVC], animated: false)
    }

    @MainActor func presentDetail(gist: Gist) {
        let detailVC = GistDetailVC(viewModel: GistDetailVM(gist: gist))
        rootViewController.pushViewController(detailVC, animated: true)
    }
}
