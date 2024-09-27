//
//  LoginViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, BMIViewControllerDelegate {

    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let signupButton = UIButton()
    let loginButton = UIButton()
    let forgotPasswordButton = UIButton()  // Forgot Password button

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Login"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(tapGesture)
        // Check if the user is already logged in
        if let currentUser = Auth.auth().currentUser {
            // Reload user data to ensure email verification status is up-to-date
            currentUser.reload { error in
                if currentUser.isEmailVerified {
                    // Show BMI Calculator or go to home
                    self.showBMIAfterLogin()
                } else {
                    // Prompt to verify email if not verified
                    self.showError(message: "Please verify your email before logging in.")
                }
            }
        } else {
            // Set up UI elements if not logged in
            setupUI()
        }
    }

    func setupUI() {
        // Email text field
        emailTextField.placeholder = "Enter email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.translatesAutoresizingMaskIntoConstraints = false

        // Password text field
        passwordTextField.placeholder = "Enter password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false

        // Login button
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.layer.cornerRadius = 10
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false

        // Sign up button
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.setTitleColor(.systemBlue, for: .normal)
        signupButton.addTarget(self, action: #selector(goToSignup), for: .touchUpInside)
        signupButton.translatesAutoresizingMaskIntoConstraints = false

        // Forgot password button
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.setTitleColor(.systemBlue, for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false

        // Add elements to the view
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signupButton)
        view.addSubview(forgotPasswordButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emailTextField.widthAnchor.constraint(equalToConstant: 250),

            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),

            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalToConstant: 100),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),

            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgotPasswordButton.topAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: 20)
        ])
    }

    // Go to Signup ViewController
    @objc func goToSignup() {
        let signupVC = SignupViewController()
        navigationController?.pushViewController(signupVC, animated: true)
    }

    // Handle Login
    @objc func handleLogin() {
        guard let email = emailTextField.text, isValidEmail(email),
              let password = passwordTextField.text, isValidPassword(password) else {
            showError(message: "Please enter a valid email and password.")
            return
        }

        // Firebase Auth - Sign In with Email and Password
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showError(message: error.localizedDescription)
                return
            }

            guard let currentUser = Auth.auth().currentUser else { return }

            // Check if the user has verified their email after logging in
            currentUser.reload { error in
                if currentUser.isEmailVerified {
                    // Show BMI Calculator after successful login and verification
                    self.showBMIAfterLogin()
                } else {
                    self.showError(message: "Please verify your email before logging in.")
                    // Optionally sign them out if their email is not verified
                    try? Auth.auth().signOut()
                }
            }
        }
    }

    // Implement showBMIAfterLogin()
    func showBMIAfterLogin() {
        // Check if BMI data exists
        if UserDefaults.standard.object(forKey: "userBMI") != nil {
            // BMI data exists, go to home
            goToHome()
        } else {
            // BMI data doesn't exist, present BMIViewController
            let bmiVC = BMIViewController()
            bmiVC.modalPresentationStyle = .formSheet
            bmiVC.delegate = self  // Set self as delegate
            present(bmiVC, animated: true, completion: nil)
        }
    }

    // Navigate to HomeViewController
    func goToHome() {
        let tabBarController = MainTabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        self.present(tabBarController, animated: true, completion: nil)
    }

    // Forgot Password
    @objc func forgotPassword() {
        guard let email = emailTextField.text, isValidEmail(email) else {
            showError(message: "Please enter a valid email address to reset your password.")
            return
        }

        // Firebase Auth - Send Password Reset Email
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.showError(message: error.localizedDescription)
                return
            }

            // Show success message after sending password reset email
            self.showSuccess(message: "Password reset email sent! Please check your inbox.")
        }
    }

    // Basic email validation
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    // Basic password validation (minimum 6 characters)
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }

    // Show error alert
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Show success alert
    func showSuccess(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Delegate method to handle BMIViewController completion
    func bmiViewControllerDidFinish(_ controller: BMIViewController) {
        controller.dismiss(animated: true) {
            self.goToHome()
        }
    }
    
    @objc func dismissKeyboard() {
            view.endEditing(true)
    }
}

