//
//  HomeViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {

    // MARK: - Properties
    private let serverURL = "https://obviously-generous-amoeba.ngrok-free.app" // Replace with your FastAPI server IP

    private let welcomeLabel = UILabel()
    private let questionnaireButton = UIButton()
    private let doSquatsButton = UIButton()
    private let openCalendarButton = UIButton(type: .system)

    private var firestoreRef: Firestore!
    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Home"
        
        setupFirestore()
        setupUI()
        addSubviewsAndConstraints()
        fetchUserName()
    }

    // MARK: - Firebase Setup
    private func setupFirestore() {
        firestoreRef = Firestore.firestore()
    }

    private func fetchUserName() {
        guard let userId = userId else {
            welcomeLabel.text = "Welcome to WorKit!"
            return
        }
        
        firestoreRef.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                self.welcomeLabel.text = "Welcome to WorKit!"
                return
            }
            
            let firstName = snapshot?.data()?["firstName"] as? String ?? "User"
            self.welcomeLabel.text = "Welcome Back \(firstName)!"
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Welcome Label
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        // Questionnaire Button
        questionnaireButton.setTitle("Fitness Goals", for: .normal)
        questionnaireButton.backgroundColor = .systemBlue
        questionnaireButton.layer.cornerRadius = 10
        questionnaireButton.setTitleColor(.white, for: .normal)
        questionnaireButton.addTarget(self, action: #selector(questionnaireTapped), for: .touchUpInside)

        // Do Squats Button
        doSquatsButton.setTitle("Do Squats", for: .normal)
        doSquatsButton.backgroundColor = .systemOrange
        doSquatsButton.layer.cornerRadius = 10
        doSquatsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        doSquatsButton.addTarget(self, action: #selector(doSquatsTapped), for: .touchUpInside)

        // Open Calendar Button
        openCalendarButton.setTitle("Open Calendar", for: .normal)
        openCalendarButton.setTitleColor(.white, for: .normal)
        openCalendarButton.backgroundColor = .black
        openCalendarButton.layer.cornerRadius = 10
        openCalendarButton.addTarget(self, action: #selector(openCalendarTapped), for: .touchUpInside)
    }

    private func addSubviewsAndConstraints() {
        // Add Subviews
        [welcomeLabel, questionnaireButton, doSquatsButton, openCalendarButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Set Constraints
        NSLayoutConstraint.activate([
            // Welcome Label
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Questionnaire Button
            questionnaireButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40),
            questionnaireButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            questionnaireButton.widthAnchor.constraint(equalToConstant: 200),
            questionnaireButton.heightAnchor.constraint(equalToConstant: 50),

            // Do Squats Button
            doSquatsButton.topAnchor.constraint(equalTo: questionnaireButton.bottomAnchor, constant: 40),
            doSquatsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doSquatsButton.widthAnchor.constraint(equalToConstant: 200),
            doSquatsButton.heightAnchor.constraint(equalToConstant: 50),

            // Open Calendar Button
            openCalendarButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openCalendarButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            openCalendarButton.widthAnchor.constraint(equalTo: questionnaireButton.widthAnchor),
            openCalendarButton.heightAnchor.constraint(equalTo: questionnaireButton.heightAnchor)
        ])
    }

    // MARK: - Button Actions
    @objc private func openCalendarTapped() {
        let calendarView = ContentView()
        calendarView.modalPresentationStyle = .fullScreen
        present(calendarView, animated: true, completion: nil)
    }

    @objc private func questionnaireTapped() {
        let questionnaireViewController = QuestionnaireViewController()
        questionnaireViewController.modalPresentationStyle = .fullScreen
        present(questionnaireViewController, animated: true, completion: nil)
    }

    @objc private func doSquatsTapped() {
        let squatViewController = SquatViewController()
        squatViewController.modalPresentationStyle = .fullScreen
        present(squatViewController, animated: true)
    }
}
