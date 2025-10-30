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
    var childCoordinators = [CoreCoordinator]()

    init(window: UIWindow) {
        self.window = window
    }

    @MainActor func start() {
        let mainCoordinator = MainTabCoordinator()
        mainCoordinator.start()
        window.rootViewController = mainCoordinator.rootViewController
        childCoordinators = [mainCoordinator]
        window.backgroundColor = .white
    }
}
