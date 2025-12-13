//
//  MainTabBarController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 21.11.2025.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupViewControllers()
        setupTabBarAppereance()
        
        self.delegate = self
    }

    // MARK: - Private Setup Methods
    private func setupViewControllers() {
        let todayVC = createTodayTab()
        let routinesVC = createRoutinesTab()
        
        viewControllers = [todayVC, routinesVC]
    }
    
    private func createTodayTab() -> UINavigationController {
        let todayVC = TodayViewController()
        todayVC.tabBarItem = UITabBarItem(
            title: "Today",
            image: UIImage(systemName: "calendar"),
            tag: 0
        )
        return UINavigationController(rootViewController: todayVC)
    }
    
    private func createRoutinesTab() -> UINavigationController {
        let routinesVC = RoutinesViewController()
        routinesVC.tabBarItem = UITabBarItem(
            title: "Routines",
            image: UIImage(systemName: "list.bullet"),
            tag: 1
        )
        return UINavigationController(rootViewController: routinesVC)
    }
    
    private func setupTabBarAppereance() {
        let appereance = UITabBarAppearance()
        appereance.configureWithOpaqueBackground()
        appereance.backgroundColor = AppColors.background
        
        appereance.stackedLayoutAppearance.selected.iconColor = AppColors.accent
        appereance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: AppColors.accent]
        
        tabBar.standardAppearance = appereance
        tabBar.scrollEdgeAppearance = appereance
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController {
            navController.popToRootViewController(animated: false)
        }
    }
}
