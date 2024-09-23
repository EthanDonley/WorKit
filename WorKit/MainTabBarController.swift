//
//  MainTabBarController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/22/24.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the Home and Account view controllers
        let homeVC = HomeViewController()
        homeVC.title = "Home"
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        let accountVC = AccountViewController()
        accountVC.title = "Account"
        let accountNav = UINavigationController(rootViewController: accountVC)
        accountNav.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.circle"), tag: 1)

        // Add both view controllers to the tab bar controller
        self.viewControllers = [homeNav, accountNav]
    }
}
