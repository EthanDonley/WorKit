import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        startCameraSession()
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Header view
        headerView.backgroundColor = .black

        // Instruction label
        instructionLabel.text = "Calibrate by matching your body with the silhouette."
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.boldSystemFont(ofSize: 22) // Larger text
        instructionLabel.textColor = .white

        // Squat count label
        squatCountLabel.text = "Squats: 0"
        squatCountLabel.font = UIFont.boldSystemFont(ofSize: 28)
        squatCountLabel.textAlignment = .center
        squatCountLabel.textColor = .white
        squatCountLabel.isHidden = true // Hidden during calibration

        // Silhouette view (translucent overlay)
        silhouetteView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        silhouetteView.isHidden = true

        // Exit button
        exitButton.setTitle("✕", for: .normal)
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        exitButton.backgroundColor = .black
        exitButton.layer.cornerRadius = 15
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)

        // Add subviews
        [headerView, instructionLabel, squatCountLabel, silhouetteView, exitButton].forEach { view.addSubview($0) }

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
            headerView.heightAnchor.constraint(equalToConstant: 80),

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

        // Check for sufficient vertical range
        let minY = skeleton.map { $0.y }.min() ?? 0
        let maxY = skeleton.map { $0.y }.max() ?? 0
        let verticalRange = maxY - minY

        if verticalRange < 0.5 {
            updateInstructionLabel(message: silhouetteMessage)
            return
        }

        // Show silhouette for calibration
        DispatchQueue.main.async {
            self.silhouetteView.isHidden = false
        }

        // If calibration is successful
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

    private func updateSquatCountLabel() {
        DispatchQueue.main.async {
            self.squatCountLabel.text = "Squats: \(self.squatCount)"
        }
    }

    @objc private func exitTapped() {
        cameraViewController?.stopSession()
        dismiss(animated: true, completion: nil)
    }
}
