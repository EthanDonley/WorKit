import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let overlayView = UIView()
    var lastFrameTime: Date = .distantPast
    let frameProcessingInterval: TimeInterval = 0.5 // Process one frame every 0.5 seconds

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    // Setup Camera
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium

        // Use the front-facing camera
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            showErrorAlert(message: "No front video device available.")
            return
        }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showErrorAlert(message: "Cannot initialize camera input: \(error.localizedDescription)")
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showErrorAlert(message: "Cannot add camera input.")
            return
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            showErrorAlert(message: "Cannot add camera output.")
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        overlayView.frame = view.bounds
        overlayView.backgroundColor = .clear
        view.addSubview(overlayView)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    // Capture Output
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let uiImage = UIImage(ciImage: ciImage)

        // Send frame to server for processing
        sendFrameToServer(image: uiImage) { [weak self] skeletonData in
            DispatchQueue.main.async {
                self?.drawSkeletonOverlay(skeletonData)
            }
        }
    }


    // Send Frame to Server
    func sendFrameToServer(image: UIImage, completion: @escaping ([CGPoint]) -> Void) {
        guard let url = URL(string: "https://obviously-generous-amoeba.ngrok-free.app/process-frame/") else {
            print("Invalid server URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG format.")
            return
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"frame.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending frame: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received from server.")
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let skeleton = jsonResponse["skeleton"] as? [[String: Any]] {
                    // Convert JSON response to [CGPoint]
                    let points = skeleton.compactMap { pointDict -> CGPoint? in
                        guard let x = pointDict["x"] as? CGFloat,
                              let y = pointDict["y"] as? CGFloat,
                              let visibility = pointDict["visibility"] as? CGFloat,
                              visibility > 0.5 else { // Visibility threshold
                            return nil
                        }
                        return CGPoint(x: x, y: y)
                    }
                    completion(points) // Pass points as [CGPoint]
                } else {
                    print("Skeleton data is missing.")
                }
            } catch {
                print("Failed to parse JSON response: \(error.localizedDescription)")
            }


        }.resume()
    }

    // Draw Skeleton Overlay
    // Draw Skeleton Overlay (using [CGPoint])
    func drawSkeletonOverlay(_ skeleton: [CGPoint]) {
        // Clear existing overlays
        overlayView.subviews.forEach { $0.removeFromSuperview() }
        overlayView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        // Get overlay dimensions
        let overlayWidth = overlayView.bounds.width
        let overlayHeight = overlayView.bounds.height

        // Assume skeleton points are normalized and scale them to overlay size
        let scaledSkeleton = skeleton.map {
            CGPoint(x: $0.x * overlayWidth, y: $0.y * overlayHeight)
        }

        // MediaPipe connections (example for full body)
        let connections = [
            (0, 1), (1, 2), (2, 3), (3, 7), // Right arm
            (0, 4), (4, 5), (5, 6), (6, 8), // Left arm
            (9, 10), // Hips
            (11, 12), // Shoulders
            (11, 13), (13, 15), // Left leg
            (12, 14), (14, 16)  // Right leg
        ]

        // Draw connections
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

        // Draw keypoints
        for point in scaledSkeleton {
            let dot = UIView(frame: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10))
            dot.backgroundColor = .green
            dot.layer.cornerRadius = 5
            overlayView.addSubview(dot)
        }
    }


    // Show Error Alert
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
