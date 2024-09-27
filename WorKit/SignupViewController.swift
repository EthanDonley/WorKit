//
//  SignupViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore  // Add Firestore if you plan to store additional user data here

class SignupViewController: UIViewController {

    let firstNameTextField = UITextField()
    let lastNameTextField = UITextField()
    let emailTextField = UITextField()
    let phoneNumberTextField = UITextField()  // New phone number text field
    let passwordTextField = UITextField()
    let confirmPasswordTextField = UITextField()
    let signupButton = UIButton()
    var activityIndicator = UIActivityIndicatorView(style: .large)  // Activity indicator for loading state

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Sign Up"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(tapGesture)
                
        // Set up UI elements
        setupUI()
    }

    func setupUI() {
        // Configure First Name TextField
        firstNameTextField.placeholder = "First Name"
        firstNameTextField.borderStyle = .roundedRect
        firstNameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(firstNameTextField)
        
        // Configure Last Name TextField
        lastNameTextField.placeholder = "Last Name"
        lastNameTextField.borderStyle = .roundedRect
        lastNameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lastNameTextField)

        // Configure Email TextField
        emailTextField.placeholder = "Enter your email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailTextField)
        
        // Configure Phone Number TextField
        phoneNumberTextField.placeholder = "Enter your phone number"
        phoneNumberTextField.borderStyle = .roundedRect
        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(phoneNumberTextField)

        // Configure Password TextField
        passwordTextField.placeholder = "Enter your password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)

        // Configure Confirm Password TextField
        confirmPasswordTextField.placeholder = "Confirm your password"
        confirmPasswordTextField.borderStyle = .roundedRect
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmPasswordTextField)

        // Configure Signup Button
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.backgroundColor = .systemGreen
        signupButton.layer.cornerRadius = 10
        signupButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signupButton)
        
        // Configure Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        // Set up Constraints
        NSLayoutConstraint.activate([
            firstNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            firstNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstNameTextField.widthAnchor.constraint(equalToConstant: 200),
            
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 20),
            lastNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lastNameTextField.widthAnchor.constraint(equalToConstant: 200),

            emailTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 20),
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.widthAnchor.constraint(equalToConstant: 200),
            
            phoneNumberTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            phoneNumberTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneNumberTextField.widthAnchor.constraint(equalToConstant: 200),

            passwordTextField.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 20),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalToConstant: 200),

            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmPasswordTextField.widthAnchor.constraint(equalToConstant: 200),

            signupButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 20),
            signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signupButton.widthAnchor.constraint(equalToConstant: 100),
            signupButton.heightAnchor.constraint(equalToConstant: 50),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: 20)
        ])
    }

    @objc func handleSignup() {
        // Validations with specific error messages
        if firstNameTextField.text?.isEmpty ?? true {
            showError(message: "Please enter your first name.")
            return
        }

        if lastNameTextField.text?.isEmpty ?? true {
            showError(message: "Please enter your last name.")
            return
        }

        guard let email = emailTextField.text, isValidEmail(email) else {
            showError(message: "Please enter a valid email.")
            return
        }

        guard let phoneNumber = phoneNumberTextField.text, isValidPhoneNumber(phoneNumber) else {
            showError(message: "Please enter a valid phone number.")
            return
        }

        guard let password = passwordTextField.text, isValidPassword(password) else {
            showError(message: "Password must be at least 6 characters long.")
            return
        }

        guard let confirmPassword = confirmPasswordTextField.text, confirmPassword == password else {
            showError(message: "Passwords do not match.")
            return
        }

        // Start loading
        activityIndicator.startAnimating()

        // Firebase Auth - Create User with Email and Password
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            self.activityIndicator.stopAnimating()  // Stop loading

            if let error = error {
                self.showError(message: error.localizedDescription)
                return
            }

            // Send email verification
            authResult?.user.sendEmailVerification(completion: { error in
                if let error = error {
                    self.showError(message: "Email verification failed: \(error.localizedDescription)")
                    return
                }

                // Show success popup and inform user to check their email
                self.showSuccess(message: "Verification email sent! Please check your inbox.")

                // Wait for email verification
                self.checkEmailVerification(authResult?.user)
            })
        }
    }

    func checkEmailVerification(_ user: User?) {
        guard let user = user else { return }

        // Continuously check whether the email has been verified
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            user.reload { (error) in
                if let error = error {
                    print("Error checking email verification status: \(error.localizedDescription)")
                } else if user.isEmailVerified {
                    timer.invalidate()  // Stop checking

                    // Add user data to Firestore only if the email is verified
                    let db = Firestore.firestore()
                    db.collection("users").document(user.uid).setData([
                        "firstName": self.firstNameTextField.text!,
                        "lastName": self.lastNameTextField.text!,
                        "email": self.emailTextField.text!,
                        "phoneNumber": self.phoneNumberTextField.text!
                    ]) { error in
                        if let error = error {
                            self.showError(message: "Failed to store user data: \(error.localizedDescription)")
                        } else {
                            self.showSuccess(message: "Your account is now verified and active!")
                        }
                    }
                }
            }
        }
    }

    // Basic email validation
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    // More robust phone number validation (basic check for length and country code formatting)
    func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegEx = "^\\+?[0-9]{10,15}$"  // Accepts optional "+" sign and 10-15 digits
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phone)
    }

    // Basic password validation (minimum 6 characters)
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func showSuccess(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func dismissKeyboard() {
            view.endEditing(true)
    }
}
