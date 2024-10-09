//
//  HomeViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let welcomeLabel = UILabel()
    let startWorkoutButton = UIButton()
    let recentWorkoutsLabel = UILabel()
    
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
        
        // Add an "Upload Image" button
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
    
    // UIImagePickerController Delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            // Dismiss the picker
            dismiss(animated: true) {
                // Call AI analysis function with the selected image
                self.performAIAnalysis(image: image)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func startWorkout() {
        print("Start workout tapped")
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func performAIAnalysis(image: UIImage) {
        // Convert UIImage to Data or URL (upload it to a server or use the local file)
        guard image.jpegData(compressionQuality: 0.8) != nil else {
            print("Failed to convert image to data")
            return
        }
        
        // Call someOAIstuff for AI analysis
        Task {
            // Assuming `someOAIstuff` accepts a URL and a prompt
            let imageUrl = ["http://example.com/image.jpg"] // Replace with your own image URL or proper reference
            let prompt = "Analyze this image"
            
            await someOAIstuff(url: imageUrl, prompt: prompt)
            
            // Show the results in a pop-up
            DispatchQueue.main.async {
                self.showAIResult(image: image, result: "Sample AI analysis result")
            }
        }
        

    }
    
    // Function to display the AI analysis result in a pop-up
    func showAIResult(image: UIImage, result: String) {
        // Create an alert
        let alertController = UIAlertController(title: "AI Analysis", message: result, preferredStyle: .alert)
        
        // Create a UIImageView for displaying the image
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        // Add the UIImageView to the alertController
        alertController.view.addSubview(imageView)
        
        // Adjust the position of the imageView in the pop-up
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 250),
            imageView.heightAnchor.constraint(equalToConstant: 250),
            imageView.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 60)
        ])
        
        // Add an "OK" button to dismiss the alert
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        
        // Present the alert
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func startCameraTapped() {
            // Trigger the camera and start pose tracking
            OpenCVWrapper.startCameraAndTrackPose()
    }

}
