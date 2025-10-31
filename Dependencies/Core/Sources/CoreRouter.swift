//
//  CoreRouter.swift
//  Core
//
//  Created by jvic on 30/10/25.
//

import Foundation
import UIKit

public protocol CoreRouter: AnyObject {
    associatedtype Destination
    @MainActor var navigationController: UINavigationController? { get }
    @MainActor func startFlow()
    @MainActor func navigateTo(_ destination: Destination)
}

// MARK: - Common Navigation Extensions

public extension CoreRouter {
    /// Push a view controller onto the navigation stack
    @MainActor func push(
        viewController: UIViewController,
        animated: Bool = true
    ) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Pop to the previous view controller
    @MainActor func pop(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    /// Pop to the root view controller
    @MainActor func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Present a view controller modally
    @MainActor func present(
        viewController: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        navigationController?.present(viewController, animated: animated, completion: completion)
    }
    
    /// Dismiss the currently presented view controller
    @MainActor func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController?.dismiss(animated: animated, completion: completion)
    }
}

// MARK: - Loading State Extensions

public extension CoreRouter {
    /// Show a loading indicator
    @MainActor func showLoading() {
        guard let navigationController = navigationController else { return }
        
        let loadingVC = UIViewController()
        loadingVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        loadingVC.modalPresentationStyle = .overFullScreen
        loadingVC.modalTransitionStyle = .crossDissolve
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        
        loadingVC.view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loadingVC.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingVC.view.centerYAnchor)
        ])
        
        navigationController.present(loadingVC, animated: true)
    }
    
    /// Hide the loading indicator
    @MainActor func hideLoading() {
        navigationController?.dismiss(animated: true)
    }
}

// MARK: - Error Handling Extensions

public extension CoreRouter {
    /// Show an error alert
    @MainActor func showError(
        title: String = "Error",
        message: String,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        navigationController?.present(alert, animated: true)
    }
}


