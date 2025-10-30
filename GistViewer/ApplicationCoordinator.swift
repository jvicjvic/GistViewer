//
//  ApplicationCoordinator.swift
//  GistsApp
//
//  Created by jvic on 30/08/24.
//

import Core
import Foundation
import UIKit

class ApplicationCoordinator: CoreCoordinator {
    let window: UIWindow
    private var mainTabRouter: MainTabRouter?

    init(window: UIWindow) {
        self.window = window
    }

    @MainActor func start() {
        let mainTabRouter = MainTabRouter()
        mainTabRouter.start()
        window.rootViewController = mainTabRouter.rootViewController
        self.mainTabRouter = mainTabRouter
        window.backgroundColor = .white
    }
}
