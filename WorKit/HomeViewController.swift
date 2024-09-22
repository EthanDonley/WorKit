//
//  HomeViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//

import Foundation

import UIKit

class HomeViewController: UIViewController {
    
    let welcomeLabel = UILabel()
    let startWorkoutButton = UIButton()
    let recentWorkoutsLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the background color
        view.backgroundColor = .white
        title = "Home"
        
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
}
