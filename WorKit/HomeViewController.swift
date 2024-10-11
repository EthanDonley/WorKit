//
//  HomeViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    let welcomeLabel = UILabel()
    let startWorkoutButton = UIButton()
    let recentWorkoutsLabel = UILabel()
<<<<<<< HEAD
=======
    
    let startCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Camera", for: .normal)
        button.addTarget(self, action: #selector(startCameraTapped), for: .touchUpInside)
        return button
    }()
>>>>>>> 9811d77 (AI/OpenCV setup (With API sensitive info stored on Firebase))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the background color
        view.backgroundColor = .white
        title = "Home"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(tapGesture)
        
        // Set up UI elements
        setupUI()
    }

    func setupUI() {
        // Welcome label setup
        welcomeLabel.text = "Welcome to WorKit!"
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = UIFont.boldSystemFont(ofSize: 30)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeLabel)
        
        // Start workout button setup
        startWorkoutButton.setTitle("Start Workout", for: .normal)
        startWorkoutButton.backgroundColor = .systemGreen
        startWorkoutButton.layer.cornerRadius = 10
        startWorkoutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        startWorkoutButton.addTarget(self, action: #selector(startWorkout), for: .touchUpInside)
        startWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startWorkoutButton)
        
        // Recent workouts label setup
        recentWorkoutsLabel.text = "Recent Workouts"
        recentWorkoutsLabel.font = UIFont.systemFont(ofSize: 20)
        recentWorkoutsLabel.textAlignment = .left
        recentWorkoutsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recentWorkoutsLabel)
        
        // Add layout constraints
        NSLayoutConstraint.activate([
            // Welcome label constraints
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Start workout button constraints
            startWorkoutButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40),
            startWorkoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startWorkoutButton.widthAnchor.constraint(equalToConstant: 200),
            startWorkoutButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Recent workouts label constraints
            recentWorkoutsLabel.topAnchor.constraint(equalTo: startWorkoutButton.bottomAnchor, constant: 40),
            recentWorkoutsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recentWorkoutsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func startWorkout() {
        // Code to start a workout goes here
        print("Start workout tapped")
    }
    
    @objc func dismissKeyboard() {
            view.endEditing(true)
        }
<<<<<<< HEAD
=======
    }

    func showAIResult(image: UIImage, result: String) {
        let alertController = UIAlertController(title: "AI Analysis", message: result, preferredStyle: .alert)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true  // Optionally hide the image if needed

        alertController.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 250),
            imageView.heightAnchor.constraint(equalToConstant: 250),
            imageView.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 120)
        ])
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }

    // Here we update the method to present CameraViewController
    @objc func startCameraTapped() {
        // Instantiate CameraViewController
        let cameraViewController = CameraViewController()
        
        // Present CameraViewController
        present(cameraViewController, animated: true, completion: nil)
    }
>>>>>>> 9811d77 (AI/OpenCV setup (With API sensitive info stored on Firebase))
}
