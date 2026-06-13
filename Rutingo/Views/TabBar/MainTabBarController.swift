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
        setupAppearance()
        setupViewControllers()
    }
    
    // MARK: - Appearance
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.cardBackground

        appearance.stackedLayoutAppearance.selected.iconColor   = AppColors.accentOrange
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: AppColors.accentOrange,
            .font: AppFonts.medium(10)
        ]

        appearance.stackedLayoutAppearance.normal.iconColor   = AppColors.secondary
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: AppColors.secondary,
            .font: AppFonts.medium(10)
        ]

        appearance.shadowColor = AppColors.border

        tabBar.standardAppearance   = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    // MARK: - View Controllers
    private func setupViewControllers() {
        let todayVC    = makeNav(root: TodayViewController(),
                                 title: "tab_today".localized,
                                 icon:  "house",
                                 selectedIcon: "house.fill")

        let blocksVC   = makeNav(root: BlocksViewController(),
                                 title: "tab_blocks".localized,
                                 icon:  "rectangle.stack",
                                 selectedIcon: "rectangle.stack.fill")

        let tasksVC    = makeNav(root: TasksViewController(),
                                 title: "tab_tasks".localized,
                                 icon:  "list.clipboard",
                                 selectedIcon: "list.clipboard.fill")

        let routinesVC = makeNav(root: RoutinesViewController(),
                                 title: "tab_routines".localized,
                                 icon:  "list.bullet",
                                 selectedIcon: "list.bullet.circle.fill")

        viewControllers = [todayVC, blocksVC, tasksVC, routinesVC]
    }
    
    // MARK: - Helpers
    private func makeNav(root: UIViewController,
                         title: String,
                         icon: String,
                         selectedIcon: String) -> UINavigationController {
        root.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: selectedIcon)
        )
        return UINavigationController(rootViewController: root)
    }
}
