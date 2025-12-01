//
//  MainTabBarController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 21.11.2025.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupViewControllers()
        setupTabBarAppereance()
        
        self.delegate = self
    }

    private func setupViewControllers() {
        let todayVC = TodayViewController()
        todayVC.tabBarItem = UITabBarItem(
            title: "Today",
            image: UIImage(systemName: "calendar"),
            tag: 0
        )
        
        let todayNav = UINavigationController(rootViewController: todayVC)
        
        let routinesVC = RoutinesViewController()
        routinesVC.tabBarItem = UITabBarItem(
            title: "Routines",
            image: UIImage(systemName: "list.bullet"),
            tag: 1
        )
        
        let routinesNav = UINavigationController(rootViewController: routinesVC)
        
        viewControllers = [todayNav, routinesNav]
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

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController {
            navController.popToRootViewController(animated: false)
        }
    }
}
