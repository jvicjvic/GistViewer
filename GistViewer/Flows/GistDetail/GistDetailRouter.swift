//
//  GistDetailRouter.swift
//  GistsApp
//
//  Created by jvic on 31/10/25.
//

import Core
import Foundation
import UIKit

enum GistDetailDestination { }

class GistDetailRouter: CoreRouter {
    weak var navigationController: UINavigationController?
    private weak var viewModel: GistDetailVM?
    private let gist: Gist
    
    init(navigationController: UINavigationController, gist: Gist) {
        self.navigationController = navigationController
        self.gist = gist
    }
    
    @MainActor func startFlow() {
        let repository = ProductionGistRepository()
        let viewModel = GistDetailVM(router: self, gist: gist, repository: repository)
        self.viewModel = viewModel
        
        let detailVC = GistDetailVC(viewModel: viewModel)
        push(viewController: detailVC)
    }
    
    func navigateTo(_ destination: GistDetailDestination) {
    }
}

