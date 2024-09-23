//
//  AccountViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {
    
    let logoutButton = UIButton()
    let bmiButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Account"

        setupUI()
    }

    func setupUI() {
        // Configure Logout Button
        configureButton(logoutButton, title: "Log Out", backgroundColor: .systemRed, action: #selector(handleLogout))
        
        // Configure BMI Button
        configureButton(bmiButton, title: "Update BMI", backgroundColor: .systemBlue, action: #selector(showBMICalculator))

        // Set layout constraints for the buttons
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            
            bmiButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bmiButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20),
            bmiButton.widthAnchor.constraint(equalToConstant: 200),
            bmiButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Helper function to configure buttons
    func configureButton(_ button: UIButton, title: String, backgroundColor: UIColor, action: Selector) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
    }

    // Handle Logout
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            // Navigate to LoginViewController
            let loginVC = LoginViewController()
            let navController = UINavigationController(rootViewController: loginVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            showError(message: "Failed to log out.")
        }
    }

    // Show BMI Calculator
    @objc func showBMICalculator() {
        let bmiVC = BMIViewController()
        bmiVC.modalPresentationStyle = .formSheet
        present(bmiVC, animated: true, completion: nil)
    }

    // Show error alert
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
