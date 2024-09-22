//
//  ProfileViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//

import UIKit

class ProfileViewController: UIViewController {

    let welcomeLabel = UILabel()
    let logoutButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Profile"
        
        // Set up UI elements
        setupUI()
        
        // Check if user is logged in and display the welcome message
        if let isLoggedIn = UserDefaults.standard.value(forKey: "isLoggedIn") as? Bool, isLoggedIn {
            welcomeLabel.text = "Welcome, user!"
        } else {
            welcomeLabel.text = "Please log in to see your profile."
        }
    }

    func setupUI() {
        // Configure welcome label
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = UIFont.systemFont(ofSize: 24)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeLabel)
        
        // Configure logout button
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.backgroundColor = .systemRed
        logoutButton.layer.cornerRadius = 10
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            welcomeLabel.widthAnchor.constraint(equalToConstant: 300),

            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            logoutButton.widthAnchor.constraint(equalToConstant: 100),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func logout() {
        // Clear the login state
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        
        // Update UI to reflect logout
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.showLoginScreen()
    }
}
