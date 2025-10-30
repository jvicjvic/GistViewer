//
//  MainTabRouter.swift
//  GistsApp
//
//  Created by jvic on 30/10/25.
//

import Core
import Foundation
import UIKit

/// Router for the main tab bar interface
/// Manages the two main tabs: Gist List and Favorites
@MainActor
class MainTabRouter {
    let rootViewController: UITabBarController
    private var gistListRouter: GistListRouter?
    private var favoritesRouter: FavoritesRouter?
    
    init() {
        rootViewController = UITabBarController()
        rootViewController.tabBar.isTranslucent = true
    }
    
    func start() {
        // Create navigation controllers for each tab
        let gistListNavController = UINavigationController()
        let favoritesNavController = UINavigationController()
        
        // Create and start routers
        let gistListRouter = GistListRouter(navigationController: gistListNavController)
        gistListRouter.startFlow()
        self.gistListRouter = gistListRouter
        
        let favoritesRouter = FavoritesRouter(navigationController: favoritesNavController)
        favoritesRouter.startFlow()
        self.favoritesRouter = favoritesRouter
        
        // Set up tab bar
        rootViewController.viewControllers = [gistListNavController, favoritesNavController]
    }
}

