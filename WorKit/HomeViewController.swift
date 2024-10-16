//
//  HomeViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//
import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let aiIntegration = AIIntegration()
    
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
        // Set the background color
        view.backgroundColor = .white
        title = "Home"
        
        view.addSubview(startCameraButton)
        view.addSubview(pickImageForAIButton)
        
        startCameraButton.translatesAutoresizingMaskIntoConstraints = false
        pickImageForAIButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startCameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startCameraButton.widthAnchor.constraint(equalToConstant: 200),
            startCameraButton.heightAnchor.constraint(equalToConstant: 50),
            
            pickImageForAIButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickImageForAIButton.topAnchor.constraint(equalTo: startCameraButton.bottomAnchor, constant: 20),
            pickImageForAIButton.widthAnchor.constraint(equalToConstant: 200),
            pickImageForAIButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupUI()
    }

    func setupUI() {
        welcomeLabel.text = "Welcome to WorKit!"
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = UIFont.boldSystemFont(ofSize: 30)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeLabel)
        
        startWorkoutButton.setTitle("Start Workout", for: .normal)
        startWorkoutButton.backgroundColor = .systemGreen
        startWorkoutButton.layer.cornerRadius = 10
        startWorkoutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        startWorkoutButton.addTarget(self, action: #selector(startWorkout), for: .touchUpInside)
        startWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startWorkoutButton)
        
        recentWorkoutsLabel.text = "Recent Workouts"
        recentWorkoutsLabel.font = UIFont.systemFont(ofSize: 20)
        recentWorkoutsLabel.textAlignment = .left
        recentWorkoutsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recentWorkoutsLabel)
        
        questionnaireButton.setTitle("Fitness Goals", for: .normal)
        questionnaireButton.backgroundColor = .systemBlue
        questionnaireButton.layer.cornerRadius = 10
        questionnaireButton.setTitleColor(.white, for: .normal)
        questionnaireButton.translatesAutoresizingMaskIntoConstraints = false
        questionnaireButton.addTarget(self, action: #selector(questionnaireTapped), for: .touchUpInside)
        view.addSubview(questionnaireButton)
        
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
            recentWorkoutsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc func startWorkout() {
        print("Start workout tapped")
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // Method for the "Pick Image for AI" button
    @objc func pickImageForAITapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            dismiss(animated: true) {
                self.performAIAnalysis(image: image)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func performAIAnalysis(image: UIImage) {
        aiIntegration.uploadImageToFirebase(image) { [weak self] imageUrl in
            guard let imageUrl = imageUrl else {
                print("Failed to upload image or get URL")
                return
            }
            
            Task {
                let prompt = "Analyze this image"
                let analysisResult = await self?.aiIntegration.someOAIstuff(url: [imageUrl], prompt: prompt)
                
                DispatchQueue.main.async {
                    self?.showAIResult(image: image, result: analysisResult ?? "No analysis result")
                }
            }
        }
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

    @objc func startCameraTapped() {
        let cameraViewController = CameraViewController()
        present(cameraViewController, animated: true, completion: nil)
    }

    @objc func questionnaireTapped() {
        print("Button was tapped!")
        let questionnaireVC = QuestionnaireViewController()
        self.present(questionnaireVC, animated: true, completion: nil)
    }
}
