//
//  MainTabBarController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 21.11.2025.
//

import UIKit

class MainTabBarController: UIViewController {
    
    // MARK: - Properties
    private var viewControllers: [UIViewController] = []
    private var selectedIndex: Int = 0
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var customTabBar: CustomTabBarView = {
        let items: [String] = [
            "square.grid.2x2",
            "rectangle.stack",
            "list.bullet"
        ]
        let tabBar = CustomTabBarView(items: items)
        tabBar.delegate = self
        return tabBar
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupViewControllers()
        setupUI()
        showViewController(at: 0)
    }
    
    // MARK: - Setup
    private func setupViewControllers() {
        let todayVC  = createTodayTab()
        let blocksVC = createBlocksTab()
        let tasksVC  = createTasksTab()
        
        viewControllers = [todayVC, blocksVC, tasksVC]
    }
    
    private func createTodayTab() -> UINavigationController {
        let todayVC = TodayViewController()
        return UINavigationController(rootViewController: todayVC)
    }
    
    private func createBlocksTab() -> UINavigationController {
        let vc = BlocksViewController()
        return UINavigationController(rootViewController: vc)
    }

    private func createTasksTab() -> UINavigationController {
        let vc = TasksViewController()
        return UINavigationController(rootViewController: vc)
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        view.addSubview(customTabBar)
        
        let tabBarHeight: CGFloat = view.frame.height < 800 ? 65 : 90
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: customTabBar.topAnchor),
            
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: tabBarHeight)
        ])
    }

    private func showViewController(at index: Int) {
        if selectedIndex < viewControllers.count {
            let oldVC = viewControllers[selectedIndex]
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParent()
        }
        
        selectedIndex = index
        let newVC = viewControllers[index]
        
        if let navVC = newVC as? UINavigationController {
            navVC.popToRootViewController(animated: false)
        }
        
        addChild(newVC)
        newVC.view.frame = containerView.bounds
        newVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(newVC.view)
        
        NSLayoutConstraint.activate([
            newVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            newVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        newVC.didMove(toParent: self)
    }
}

// MARK: - CustomTabBarDelegate
extension MainTabBarController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        showViewController(at: index)
    }
    
    func didTapAddButton() {
        let addRoutineVC = AddRoutineViewController()
        let routinesViewModel = RoutinesViewModel()
        
        addRoutineVC.onSave = { name, frequency, feeling, motivation, blockType, hasReminder, reminderTime, startHour, endHour in
            routinesViewModel.addRoutine(
                name: name,
                frequency: frequency,
                feeling: feeling,
                motivation: motivation,
                blockType: blockType,
                hasReminder: hasReminder,
                reminderTime: reminderTime,
                startHour: startHour,
                endHour: endHour
            ) {
                NotificationCenter.default.post(
                    name: NSNotification.Name("RoutineAdded"),
                    object: nil
                )
            }
        }
        
        let navVC = UINavigationController(rootViewController: addRoutineVC)
        present(navVC, animated: true)
    }
}
