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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Sign Up"

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
            signupButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func handleSignup() {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let email = emailTextField.text, isValidEmail(email),
              let phoneNumber = phoneNumberTextField.text, isValidPhoneNumber(phoneNumber),
              let password = passwordTextField.text, isValidPassword(password),
              let confirmPassword = confirmPasswordTextField.text, confirmPassword == password else {
            showError(message: "Please enter all fields correctly and confirm your password.")
            return
        }

        // Firebase Auth - Create User with Email and Password
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showError(message: error.localizedDescription)
                return
            }

            // Add First Name, Last Name, and Phone Number to the User Profile or Firestore
            let changeRequest = authResult?.user.createProfileChangeRequest()
            changeRequest?.displayName = "\(firstName) \(lastName)"
            changeRequest?.commitChanges { error in
                if let error = error {
                    self.showError(message: error.localizedDescription)
                    return
                }

                // Store phone number in Firestore (Optional)
                let db = Firestore.firestore()
                db.collection("users").document(authResult!.user.uid).setData([
                    "firstName": firstName,
                    "lastName": lastName,
                    "email": email,
                    "phoneNumber": phoneNumber
                ]) { error in
                    if let error = error {
                        self.showError(message: "Failed to store user data: \(error.localizedDescription)")
                        return
                    }

                    // Send email verification
                    authResult?.user.sendEmailVerification(completion: { error in
                        if let error = error {
                            self.showError(message: "Email verification failed: \(error.localizedDescription)")
                            return
                        }

                        // Inform the user that a verification email was sent
                        self.showSuccess(message: "Verification email sent! Please check your inbox.")

                        // Dismiss the sign-up view and navigate to home (optional)
                        let homeVC = HomeViewController()
                        let navController = UINavigationController(rootViewController: homeVC)
                        navController.modalPresentationStyle = .fullScreen
                        self.present(navController, animated: true, completion: nil)
                    })
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

    // Basic phone number validation (simple check for length)
    func isValidPhoneNumber(_ phone: String) -> Bool {
        return phone.count >= 10 // You can add a more robust validation
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
}








