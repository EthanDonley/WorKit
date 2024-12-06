import UIKit
import FirebaseFirestore
import FirebaseAuth

class SquatViewController: UIViewController {
    private let headerView = UIView()
    private let instructionLabel = UILabel()
    private let squatCountLabel = UILabel()
    private let silhouetteView = UIView()
    private let exitButton = UIButton()

    private var cameraViewController: CameraViewController?
    private var isCalibrated = false
    private var squatCount = 0
    private var isSquatting = false
    private var feedbackGiven = false
    
    private var firestoreRef: Firestore!
    private var userId: String? {
            return Auth.auth().currentUser?.uid
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        startCameraSession()
        setupFirestore()
        resetDailyCountIfNeeded()
    }
    
    private func setupFirestore() {
        firestoreRef = Firestore.firestore()
    }
    
    private func resetDailyCountIfNeeded() {
        guard let userId = userId else {
            print("Error: User is not authenticated.")
            return
        }

        let today = getFormattedDate()
        let userWorkoutsCollection = firestoreRef.collection("users").document(userId).collection("workouts")
        let todayWorkoutDoc = userWorkoutsCollection.document(today)

        todayWorkoutDoc.getDocument { [weak self] snapshot, error in
            guard let self = self, error == nil else {
                self?.squatCount = 0
                self?.updateWorkoutData()
                return
            }

            let data = snapshot?.data()
            let lastUpdated = data?["lastUpdated"] as? String ?? ""

            if lastUpdated != today {
                self.squatCount = 0
                self.updateWorkoutData()
            } else {
                self.squatCount = data?["squatCount"] as? Int ?? 0
                self.updateSquatCountLabel()
            }
        }
    }



    private func updateWorkoutData() {
        guard let userId = userId else {
            print("Error: User is not authenticated.")
            return
        }

        let today = getFormattedDate()
        let userWorkoutsCollection = firestoreRef.collection("users").document(userId).collection("workouts")
        let todayWorkoutDoc = userWorkoutsCollection.document(today)

        todayWorkoutDoc.setData([
            "squatCount": squatCount,
            "lastUpdated": today
        ], merge: true) { error in
            if let error = error {
                print("Error updating workout data: \(error.localizedDescription)")
            } else {
                print("Workout data updated successfully for \(today)")
            }
        }
    }


    private func updateSquatCountLabel() {
        DispatchQueue.main.async {
            self.squatCountLabel.text = "Squats: \(self.squatCount)"
        }
    }

    // MARK: - UI Setup
    // Updated setupUI function
    private func setupUI() {
            // Header view
            headerView.backgroundColor = .black
            let headerHeight: CGFloat = 120 // Reduced height

            // Instruction label (inside the header)
            instructionLabel.text = "Calibrate by matching your body with the silhouette."
            instructionLabel.numberOfLines = 0
            instructionLabel.textAlignment = .center
            instructionLabel.font = UIFont.boldSystemFont(ofSize: 22)
            instructionLabel.textColor = .white

            // Squat count label
            squatCountLabel.text = "Squats: 0"
            squatCountLabel.font = UIFont.boldSystemFont(ofSize: 28)
            squatCountLabel.textAlignment = .center
            squatCountLabel.textColor = .white
            squatCountLabel.isHidden = true // Hidden during calibration

            // Silhouette view (bigger, slightly transparent, disappears after calibration)
            if let silhouetteImage = UIImage(named: "silhouetteImage") {
                let silhouetteImageView = UIImageView(image: silhouetteImage)
                silhouetteImageView.contentMode = .scaleAspectFit
                silhouetteImageView.alpha = 0.4 // Reduced opacity
                silhouetteImageView.tintColor = UIColor.green
                silhouetteImageView.image = silhouetteImage.withRenderingMode(.alwaysTemplate)
                silhouetteView.addSubview(silhouetteImageView)

                // Auto Layout for silhouetteImageView
                silhouetteImageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    silhouetteImageView.centerXAnchor.constraint(equalTo: silhouetteView.centerXAnchor),
                    silhouetteImageView.centerYAnchor.constraint(equalTo: silhouetteView.centerYAnchor),
                    silhouetteImageView.widthAnchor.constraint(equalTo: silhouetteView.widthAnchor, multiplier: 1.6),
                    silhouetteImageView.heightAnchor.constraint(equalTo: silhouetteView.heightAnchor, multiplier: 1.6)
                ])
            }

            // Exit button
            exitButton.setTitle("✕", for: .normal)
            exitButton.setTitleColor(.white, for: .normal)
            exitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            exitButton.backgroundColor = .black
            exitButton.layer.cornerRadius = 15
            exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)

            // Add subviews
            [headerView, silhouetteView, exitButton].forEach { view.addSubview($0) }
            headerView.addSubview(instructionLabel)
            view.addSubview(squatCountLabel)

            // Auto Layout
            headerView.translatesAutoresizingMaskIntoConstraints = false
            instructionLabel.translatesAutoresizingMaskIntoConstraints = false
            squatCountLabel.translatesAutoresizingMaskIntoConstraints = false
            silhouetteView.translatesAutoresizingMaskIntoConstraints = false
            exitButton.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: view.topAnchor),
                headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                headerView.heightAnchor.constraint(equalToConstant: headerHeight),

                instructionLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
                instructionLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                instructionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
                instructionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),

                squatCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                squatCountLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),

                silhouetteView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                silhouetteView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                silhouetteView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                silhouetteView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                exitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                exitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                exitButton.widthAnchor.constraint(equalToConstant: 30),
                exitButton.heightAnchor.constraint(equalToConstant: 30),
            ])
        }





    private func startCameraSession() {
            cameraViewController = CameraViewController()
            cameraViewController?.onPoseDetected = { [weak self] skeleton in
                guard let self = self else { return }
                if !self.isCalibrated {
                    self.checkCalibration(skeleton: skeleton)
                } else {
                    self.trackSquats(skeleton: skeleton)
                }
            }

            guard let cameraVC = cameraViewController else { return }
            addChild(cameraVC)
            view.insertSubview(cameraVC.view, at: 0)
            cameraVC.didMove(toParent: self)
            cameraVC.startSession()
        }

    private func checkCalibration(skeleton: [CGPoint]) {
            guard skeleton.count >= 33 else { return }

            let silhouetteMessage = "Adjust your position to match the silhouette."
            let successMessage = "Calibration complete! Start doing squats."

            let minY = skeleton.map { $0.y }.min() ?? 0
            let maxY = skeleton.map { $0.y }.max() ?? 0
            let verticalRange = maxY - minY

            if verticalRange < 0.5 {
                updateInstructionLabel(message: silhouetteMessage)
                return
            }

            DispatchQueue.main.async {
                self.silhouetteView.isHidden = true // Hide silhouette after calibration
            }

            isCalibrated = true
            updateInstructionLabel(message: successMessage)
            DispatchQueue.main.async {
                self.squatCountLabel.isHidden = false
            }
        }

    private func trackSquats(skeleton: [CGPoint]) {
        guard skeleton.count >= 33 else { return }

        let hip = skeleton[23]
        let knee = skeleton[25]
        let ankle = skeleton[27]
        let shoulder = skeleton[11]
        let backStraightThreshold: CGFloat = 0.1 // Adjust based on testing

        let kneeAngle = calculateAngle(a: hip, b: knee, c: ankle)
        let backStraightness = abs(shoulder.x - hip.x) // Horizontal alignment

        if kneeAngle > 120, kneeAngle < 160, !feedbackGiven {
            updateFeedback(message: "Lower your hips more.")
            feedbackGiven = true
            return
        }

        if backStraightness > backStraightThreshold {
            updateFeedback(message: "Keep your back straight!")
            return
        }

        if kneeAngle < 90, !isSquatting {
            isSquatting = true
            feedbackGiven = false
            updateFeedback(message: "Good squat! Now stand up.")
        } else if kneeAngle > 160, isSquatting {
            isSquatting = false
            squatCount += 1
            updateSquatCountLabel()
            updateWorkoutData()
            updateFeedback(message: "Great! Do the next squat.")
        }
    }

    private func calculateAngle(a: CGPoint, b: CGPoint, c: CGPoint) -> CGFloat {
        let ba = CGPoint(x: a.x - b.x, y: a.y - b.y)
        let bc = CGPoint(x: c.x - b.x, y: c.y - b.y)
        let dotProduct = ba.x * bc.x + ba.y * bc.y
        let magnitudeA = sqrt(ba.x * ba.x + ba.y * ba.y)
        let magnitudeB = sqrt(bc.x * bc.x + bc.y * bc.y)
        return acos(dotProduct / (magnitudeA * magnitudeB)) * (180 / .pi)
    }

    private func updateInstructionLabel(message: String) {
        DispatchQueue.main.async {
            self.instructionLabel.text = message
        }
    }

    private func updateFeedback(message: String) {
        DispatchQueue.main.async {
            self.instructionLabel.text = message
        }
    }

    @objc private func exitTapped() {
        cameraViewController?.stopSession()
        dismiss(animated: true, completion: nil)
    }
    
    private func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
