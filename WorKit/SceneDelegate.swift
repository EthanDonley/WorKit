//
//  SceneDelegate.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//

import Firebase
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Set up the window
        window = UIWindow(windowScene: windowScene)

        // Check Firebase Auth to see if the user is logged in
        if let _ = Auth.auth().currentUser {
            // User is logged in, show the main app
            showMainApp()
        } else {
            // User is not logged in, show the login screen
            showLoginScreen()
        }
    }

    // Function to show the login screen
    func showLoginScreen() {
        // Load LoginViewController from storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let navigationController = UINavigationController(rootViewController: loginViewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    // Function to show the main app (UITabBarController)
    func showMainApp() {
        // Load view controllers from storyboard or initialize them programmatically if not using storyboard
        let tabBarController = UITabBarController()

        // Home view controller
        let homeViewController = HomeViewController()
        homeViewController.title = "Home"
        homeViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)

        // BMI Calculator view controller
        let bmiViewController = BMIViewController()
        bmiViewController.title = "BMI Calculator"
        bmiViewController.tabBarItem = UITabBarItem(title: "BMI", image: UIImage(systemName: "heart.fill"), tag: 1)

        // Profile view controller
        let profileViewController = ProfileViewController()
        profileViewController.title = "Profile"
        profileViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)

        // Set the tab bar controller's view controllers
        tabBarController.viewControllers = [homeViewController, bmiViewController, profileViewController]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}
