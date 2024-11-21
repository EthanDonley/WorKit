//
//  HomeViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//
import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let serverURL = "https://obviously-generous-amoeba.ngrok-free.app" // Replace with your FastAPI server IP

    let welcomeLabel = UILabel()
    let startWorkoutButton = UIButton()
    let recentWorkoutsLabel = UILabel()
    let questionnaireButton = UIButton()

    // "Pick Image for AI" button
    let pickImageForAIButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pick Image for AI", for: .normal)
        button.addTarget(self, action: #selector(pickImageForAITapped), for: .touchUpInside)
        return button
    }()
    
    let startCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Camera", for: .normal)
        button.addTarget(self, action: #selector(startCameraTapped), for: .touchUpInside)
        return button
    }()

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
    }

    func addSubviewsAndConstraints() {
        [welcomeLabel, startWorkoutButton, recentWorkoutsLabel, questionnaireButton, pickImageForAIButton, startCameraButton].forEach { view.addSubview($0) }
        
        // Set up constraints
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        startWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        recentWorkoutsLabel.translatesAutoresizingMaskIntoConstraints = false
        questionnaireButton.translatesAutoresizingMaskIntoConstraints = false
        pickImageForAIButton.translatesAutoresizingMaskIntoConstraints = false
        startCameraButton.translatesAutoresizingMaskIntoConstraints = false

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
            
            startCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startCameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startCameraButton.widthAnchor.constraint(equalToConstant: 200),
            startCameraButton.heightAnchor.constraint(equalToConstant: 50),
            
            pickImageForAIButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickImageForAIButton.topAnchor.constraint(equalTo: startCameraButton.bottomAnchor, constant: 20),
            pickImageForAIButton.widthAnchor.constraint(equalToConstant: 200),
            pickImageForAIButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Button Actions
    @objc func startWorkout() {
        print("Start workout tapped")
    }

    @objc func questionnaireTapped() {
        print("Questionnaire tapped")
    }

    @objc func startCameraTapped() {
        // Open CameraViewController for real-time processing (implementation to follow)
        let cameraViewController = CameraViewController()
        present(cameraViewController, animated: true)
    }

    @objc func pickImageForAITapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            dismiss(animated: true) {
                self.performAIAnalysis(image: image)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    // MARK: - Perform AI Analysis
    func performAIAnalysis(image: UIImage) {
        guard let url = URL(string: "\(serverURL)/analyze/") else {
            print("Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }

        // Prepare multipart form-data
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // Send request to server
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let result = response["ai_analysis"] as? String ?? "No analysis result"
                DispatchQueue.main.async {
                    self?.showAIResult(image: image, result: result)
                }
            }
        }.resume()
    }

    // MARK: - Show AI Result
    func showAIResult(image: UIImage, result: String) {
        let alertController = UIAlertController(title: "AI Analysis", message: result, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
