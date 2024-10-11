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
        startCameraButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startCameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startCameraButton.widthAnchor.constraint(equalToConstant: 200),
            startCameraButton.heightAnchor.constraint(equalToConstant: 50)
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
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startWorkoutButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40),
            startWorkoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startWorkoutButton.widthAnchor.constraint(equalToConstant: 200),
            startWorkoutButton.heightAnchor.constraint(equalToConstant: 50),
            recentWorkoutsLabel.topAnchor.constraint(equalTo: startWorkoutButton.bottomAnchor, constant: 40),
            recentWorkoutsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recentWorkoutsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        let uploadImageButton = UIButton()
        uploadImageButton.setTitle("Upload Image", for: .normal)
        uploadImageButton.backgroundColor = .systemBlue
        uploadImageButton.layer.cornerRadius = 10
        uploadImageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        uploadImageButton.addTarget(self, action: #selector(uploadImage), for: .touchUpInside)
        uploadImageButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uploadImageButton)
        
        NSLayoutConstraint.activate([
            uploadImageButton.topAnchor.constraint(equalTo: recentWorkoutsLabel.bottomAnchor, constant: 40),
            uploadImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadImageButton.widthAnchor.constraint(equalToConstant: 200),
            uploadImageButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func uploadImage() {
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
            
            // Questionnaire Button setup
            questionnaireButton.setTitle("Fitness Goals", for: .normal)
            questionnaireButton.backgroundColor = .systemBlue
            questionnaireButton.layer.cornerRadius = 10
            questionnaireButton.setTitleColor(.white, for: .normal)
            questionnaireButton.translatesAutoresizingMaskIntoConstraints = false
            questionnaireButton.addTarget(self, action: #selector(questionnaireTapped), for: .touchUpInside)
            view.addSubview(questionnaireButton)
            
            // Add layout constraints
            NSLayoutConstraint.activate([
                // Welcome label constraints
                welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
                welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                // Questionnaire button constraints
                questionnaireButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40),
                questionnaireButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                questionnaireButton.widthAnchor.constraint(equalToConstant: 200),
                questionnaireButton.heightAnchor.constraint(equalToConstant: 50),
                
                // Start workout button constraints
                startWorkoutButton.topAnchor.constraint(equalTo: questionnaireButton.bottomAnchor, constant: 40),
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
        print("Start workout tapped")
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
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
    @objc func questionnaireTapped() {
            print("Button was tapped!")
                // Instantiate the QuestionnaireViewController
               let questionnaireVC = QuestionnaireViewController()
               // Present it modally
               self.present(questionnaireVC, animated: true, completion: nil)
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
}

