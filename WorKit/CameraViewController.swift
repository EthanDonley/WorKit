import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let overlayView = UIView()
    let serverURL = "https://obviously-generous-amoeba.ngrok-free.app/process-frame/"
    let frameProcessingInterval: TimeInterval = 0.1 // Process one frame every 0.5 seconds
    var lastFrameTime: Date = .distantPast
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCamera()
        setupOverlayView()
    }
    
    // Setup Camera
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            showErrorAlert(message: "No front video device available.")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                showErrorAlert(message: "Cannot add camera input.")
                return
            }
        } catch {
            showErrorAlert(message: "Cannot initialize camera input: \(error.localizedDescription)")
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
        
        captureSession.startRunning()
    }
    
    private func setupOverlayView() {
        overlayView.frame = view.bounds
        overlayView.backgroundColor = .clear
        view.addSubview(overlayView)
    }
    
    // Capture Output
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard Date().timeIntervalSince(lastFrameTime) > frameProcessingInterval else { return }
        lastFrameTime = Date()
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let uiImage = UIImage(ciImage: ciImage)
        
        // Correct image orientation
        let correctedImage = fixImageOrientation(image: uiImage)
        
        processFrame(image: correctedImage)
    }
    
    private func processFrame(image: UIImage) {
        // Perform rotation on a background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let rotatedImage = self?.rotateImage90Degrees(image: image) else {
                print("Failed to rotate image.")
                return
            }
            
            // Send the rotated image to the server
            self?.sendFrameToServer(image: rotatedImage) { skeleton in
                DispatchQueue.main.async {
                    self?.drawSkeletonOverlay(skeleton)
                }
            }
        }
    }

    private func rotateImage90Degrees(image: UIImage) -> UIImage? {
        // Ensure we have a CGImage
        guard let cgImage = image.cgImage ?? CIContext().createCGImage(image.ciImage ?? CIImage(), from: image.ciImage?.extent ?? CGRect.zero) else {
            print("Failed to create CGImage from UIImage.")
            return nil
        }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: cgImage.height, height: cgImage.width)) // Rotate width and height
        return renderer.image { context in
            // Rotate the context 90 degrees
            context.cgContext.translateBy(x: CGFloat(cgImage.height) / 2, y: CGFloat(cgImage.width) / 2)
            context.cgContext.rotate(by: .pi / 2)
            context.cgContext.scaleBy(x: 1.0, y: -1.0)

            // Draw the image into the rotated context
            let rect = CGRect(x: -CGFloat(cgImage.width) / 2, y: -CGFloat(cgImage.height) / 2, width: CGFloat(cgImage.width), height: CGFloat(cgImage.height))
            context.cgContext.draw(cgImage, in: rect)
        }
    }



    
    private func sendFrameToServer(image: UIImage, completion: @escaping ([CGPoint]) -> Void) {
        guard let url = URL(string: serverURL) else {
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
                    let points = skeleton.compactMap { pointDict -> CGPoint? in
                        guard let x = pointDict["x"] as? CGFloat,
                              let y = pointDict["y"] as? CGFloat,
                              let visibility = pointDict["visibility"] as? CGFloat,
                              visibility > 0.5 else { // Visibility threshold
                            return nil
                        }
                        return CGPoint(x: x, y: y)
                    }
                    completion(points)
                } else {
                    print("Skeleton data is missing.")
                }
            } catch {
                print("Failed to parse JSON response: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func drawSkeletonOverlay(_ skeleton: [CGPoint]) {
        overlayView.subviews.forEach { $0.removeFromSuperview() }
        overlayView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        // Mirror the X coordinates
        let mirroredSkeleton = skeleton.map {
            CGPoint(x: overlayView.bounds.width - ($0.x * overlayView.bounds.width), y: $0.y * overlayView.bounds.height)
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
            guard start < mirroredSkeleton.count, end < mirroredSkeleton.count else { continue }
            let path = UIBezierPath()
            path.move(to: mirroredSkeleton[start])
            path.addLine(to: mirroredSkeleton[end])

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.green.cgColor
            shapeLayer.lineWidth = 2
            overlayView.layer.addSublayer(shapeLayer)
        }

        for point in mirroredSkeleton {
            let dot = UIView(frame: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10))
            dot.backgroundColor = .green
            dot.layer.cornerRadius = 5
            overlayView.addSubview(dot)
        }
    }

    
    private func fixImageOrientation(image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        if image.imageOrientation == .up {
            return image // Orientation is correct
        }

        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in
            UIImage(cgImage: cgImage, scale: image.scale, orientation: .up).draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
