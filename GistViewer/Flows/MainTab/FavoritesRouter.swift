//
//  FavoritesRouter.swift
//  GistsApp
//
//  Created by jvic on 30/10/25.
//

import Core
import FavoriteGists
import Foundation
import UIKit

/// Navigation destinations for the Favorites flow
enum FavoritesDestination {
    case gistDetail(Gist)
}

/// Router for the Favorites feature
class FavoritesRouter: CoreRouter {
    weak var navigationController: UINavigationController?
    private weak var viewModel: FavoritesListVM<Gist>?
    private var detailRouter: GistDetailRouter?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func startFlow() {
        let viewModel = FavoritesListVM<Gist>()
        viewModel.setItemSelectedHandler { [weak self] gist in
            self?.navigateTo(.gistDetail(gist))
        }
        self.viewModel = viewModel
        
        let favoritesVC = FavoritesListVC(viewModel: viewModel)
        navigationController?.setViewControllers([favoritesVC], animated: false)
    }
    
    @MainActor func navigateTo(_ destination: FavoritesDestination) {
        switch destination {
        case .gistDetail(let gist):
            presentDetail(gist: gist)
        }
    }
    
    @MainActor private func presentDetail(gist: Gist) {
        guard let navigationController = navigationController else { return }
        let router = GistDetailRouter(navigationController: navigationController, gist: gist)
        detailRouter = router
        router.startFlow()
    }
}

