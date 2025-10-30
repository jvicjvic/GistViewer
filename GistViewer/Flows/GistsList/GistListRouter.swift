//
//  GistListRouter.swift
//  GistsApp
//
//  Created by jvic on 30/10/25.
//

import Core
import Foundation
import UIKit

/// Navigation destinations for the Gist List flow
enum GistListDestination {
    case gistDetail(Gist)
}

/// Router for the Gist List feature
class GistListRouter: CoreRouter {
    weak var navigationController: UINavigationController?
    private weak var viewModel: GistsListVM?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func startFlow() {
        let repository = ProductionGistRepository()
        let viewModel = GistsListVM(router: self, repository: repository)
        self.viewModel = viewModel
        
        let listVC = GistsListVC(viewModel: viewModel)
        navigationController?.setViewControllers([listVC], animated: false)
    }
    
    func navigateTo(_ destination: GistListDestination) {
        switch destination {
        case .gistDetail(let gist):
            presentDetail(gist: gist)
        }
    }

    @MainActor
    private func presentDetail(gist: Gist) {
        let detailVM = GistDetailVM(gist: gist)
        let detailVC = GistDetailVC(viewModel: detailVM)
        push(viewController: detailVC)
    }
}

