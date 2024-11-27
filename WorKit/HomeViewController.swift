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

    func performAIAnalysis(image: UIImage) {
        guard let url = URL(string: "\(serverURL)/process-frame/") else {
            print("Invalid server URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let data = data, let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let skeleton = response["skeleton"] as? [[String: CGFloat]] {
                DispatchQueue.main.async {
                    self?.showImageWithSkeleton(image: image, skeleton: skeleton)
                }
            } else {
                print("Failed to parse response")
            }
        }.resume()
    }

    func showImageWithSkeleton(image: UIImage, skeleton: [[String: CGFloat]]) {
        // Create an image view to display the image
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)
        
        // Get the actual image size displayed in the imageView
        guard let imageSize = image.sizeInView(imageView: imageView) else { return }
        
        // Create an overlay for the skeleton
        let overlayView = UIView(frame: CGRect(origin: CGPoint(x: (view.bounds.width - imageSize.width) / 2,
                                                                y: imageView.frame.origin.y + (imageView.bounds.height - imageSize.height) / 2),
                                               size: imageSize))
        overlayView.backgroundColor = .clear
        view.addSubview(overlayView)

        // Scale and draw the skeleton points and connections
        let scaledSkeleton = skeleton.compactMap { pointDict -> CGPoint? in
            guard let x = pointDict["x"], let y = pointDict["y"] else { return nil }
            let scaledX = x * overlayView.bounds.width
            let scaledY = y * overlayView.bounds.height
            // Ensure the points are within the image bounds
            return scaledX >= 0 && scaledX <= overlayView.bounds.width &&
                   scaledY >= 0 && scaledY <= overlayView.bounds.height
                ? CGPoint(x: scaledX, y: scaledY)
                : nil
        }

        let connections = [
            (0, 1), (1, 2), (2, 3), (3, 7), // Right arm
            (0, 4), (4, 5), (5, 6), (6, 8), // Left arm
            (9, 10), // Hips
            (11, 12), // Shoulders
            (11, 13), (13, 15), // Left leg
            (12, 14), (14, 16)  // Right leg
        ]

        for (start, end) in connections {
            guard start < scaledSkeleton.count, end < scaledSkeleton.count else { continue }
            let path = UIBezierPath()
            path.move(to: scaledSkeleton[start])
            path.addLine(to: scaledSkeleton[end])

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.green.cgColor
            shapeLayer.lineWidth = 2
            overlayView.layer.addSublayer(shapeLayer)
        }

        for point in scaledSkeleton {
            let dot = UIView(frame: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10))
            dot.backgroundColor = .green
            dot.layer.cornerRadius = 5
            overlayView.addSubview(dot)
        }

        // Add a close button to dismiss the overlay
        let closeButton = UIButton(frame: CGRect(x: 20, y: 40, width: 100, height: 40))
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = .red
        closeButton.layer.cornerRadius = 5
        closeButton.addTarget(self, action: #selector(closeSkeletonOverlay), for: .touchUpInside)
        imageView.addSubview(closeButton)
    }



    @objc func closeSkeletonOverlay() {
        view.subviews.last?.removeFromSuperview()
    }
    
}

extension UIImage {
    func sizeInView(imageView: UIImageView) -> CGSize? {
        let imageRatio = self.size.width / self.size.height
        let viewRatio = imageView.bounds.width / imageView.bounds.height

        if imageRatio > viewRatio {
            let width = imageView.bounds.width
            let height = width / imageRatio
            return CGSize(width: width, height: height)
        } else {
            let height = imageView.bounds.height
            let width = height * imageRatio
            return CGSize(width: width, height: height)
        }
    }
}
