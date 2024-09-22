//
//  AccountViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//

import Foundation

import UIKit

class AccountViewController: UIViewController {

    let usernameTextField = UITextField()
    let passwordTextField = UITextField()
    let loginButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Account"

        // Add text fields and login button
        setupUI()
    }

    func setupUI() {
        // Set up username and password text fields and login button
        usernameTextField.placeholder = "Enter username"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false

        passwordTextField.placeholder = "Enter password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false

        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.layer.cornerRadius = 10
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)

        // Add constraints
        NSLayoutConstraint.activate([
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            usernameTextField.widthAnchor.constraint(equalToConstant: 200),

            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 200),

            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    @objc func login() {
        // Store user data in UserDefaults
        let username = usernameTextField.text
        let password = passwordTextField.text

        if username == "user" && password == "password" {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            print("User logged in!")
        } else {
            print("Invalid credentials!")
        }
    }
}
