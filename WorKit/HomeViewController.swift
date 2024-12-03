//
//  HomeViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//
import UIKit

class HomeViewController: UIViewController {
    
    let serverURL = "https://obviously-generous-amoeba.ngrok-free.app" // Replace with your FastAPI server IP

    let welcomeLabel = UILabel()
    let startWorkoutButton = UIButton()
    let recentWorkoutsLabel = UILabel()
    let questionnaireButton = UIButton()
    let doSquatsButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Home"
        
        setupUI()
        addSubviewsAndConstraints()
    }

    // MARK: - UI Setup
    func setupUI() {
        welcomeLabel.text = "Welcome to WorKit!"
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        startWorkoutButton.setTitle("Start Workout", for: .normal)
        startWorkoutButton.backgroundColor = .systemGreen
        startWorkoutButton.layer.cornerRadius = 10
        startWorkoutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        startWorkoutButton.addTarget(self, action: #selector(startWorkout), for: .touchUpInside)
        
        recentWorkoutsLabel.text = "Recent Workouts"
        recentWorkoutsLabel.font = UIFont.systemFont(ofSize: 20)
        recentWorkoutsLabel.textAlignment = .left
        
        questionnaireButton.setTitle("Fitness Goals", for: .normal)
        questionnaireButton.backgroundColor = .systemBlue
        questionnaireButton.layer.cornerRadius = 10
        questionnaireButton.setTitleColor(.white, for: .normal)
        questionnaireButton.addTarget(self, action: #selector(questionnaireTapped), for: .touchUpInside)
        
        doSquatsButton.setTitle("Do Squats", for: .normal)
        doSquatsButton.backgroundColor = .systemOrange
        doSquatsButton.layer.cornerRadius = 10
        doSquatsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        doSquatsButton.addTarget(self, action: #selector(doSquatsTapped), for: .touchUpInside)
    }

    func addSubviewsAndConstraints() {
        [welcomeLabel, startWorkoutButton, openCalendarButton, recentWorkoutsLabel, questionnaireButton, doSquatsButton].forEach { view.addSubview($0) }
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        startWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        openCalendarButton.translatesAutoresizingMaskIntoConstraints = false
        recentWorkoutsLabel.translatesAutoresizingMaskIntoConstraints = false
        questionnaireButton.translatesAutoresizingMaskIntoConstraints = false
        doSquatsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            questionnaireButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40),
            questionnaireButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            questionnaireButton.widthAnchor.constraint(equalToConstant: 200),
            questionnaireButton.heightAnchor.constraint(equalToConstant: 50),
            
            startWorkoutButton.topAnchor.constraint(equalTo: questionnaireButton.bottomAnchor, constant: 40),
            startWorkoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startWorkoutButton.widthAnchor.constraint(equalToConstant: 200),
            startWorkoutButton.heightAnchor.constraint(equalToConstant: 50),
            
            recentWorkoutsLabel.topAnchor.constraint(equalTo: startWorkoutButton.bottomAnchor, constant: 40),
            recentWorkoutsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recentWorkoutsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            doSquatsButton.topAnchor.constraint(equalTo: recentWorkoutsLabel.bottomAnchor, constant: 40),
            doSquatsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doSquatsButton.widthAnchor.constraint(equalToConstant: 200),
            doSquatsButton.heightAnchor.constraint(equalToConstant: 50),
            
            openCalendarButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openCalendarButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            openCalendarButton.widthAnchor.constraint(equalTo: questionnaireButton.widthAnchor),
            openCalendarButton.heightAnchor.constraint(equalTo: questionnaireButton.heightAnchor)
        ])
    }

    let openCalendarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Calendar", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(openCalendarTapped), for: .touchUpInside)
        return button
    }()

    
    @objc func openCalendarTapped() {
            let calendarView = ContentView()
            present(calendarView, animated: true, completion: nil)
        }
    
    
    // MARK: - Button Actions
    @objc func startWorkout() {
        print("Start workout tapped")
    }

    @objc func questionnaireTapped() {
        print("Questionnaire tapped")
    }

    @objc func doSquatsTapped() {
        let squatViewController = SquatViewController()
        present(squatViewController, animated: true)
    }
}
