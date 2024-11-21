import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let overlayView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium

        // Use the front-facing camera
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            fatalError("No front video device available")
        }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            fatalError("Cannot initialize camera input: \(error)")
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            fatalError("Cannot add camera input")
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            fatalError("Cannot add camera output")
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        overlayView.frame = view.bounds
        overlayView.backgroundColor = .clear
        view.addSubview(overlayView)

        // Start the capture session on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }


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

    func sendFrameToServer(image: UIImage, completion: @escaping ([CGPoint]) -> Void) {
        guard let url = URL(string: "https://obviously-generous-amoeba.ngrok-free.app/process-frame/") else {
            print("Invalid server URL")
            return
        }


        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG format")
            return
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"frame.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error sending frame: \(error.localizedDescription)")
                return
            }

            if let data = data, let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let skeleton = response["skeleton"] as? [[String: CGFloat]] {
                let points = skeleton.map { CGPoint(x: $0["x"]!, y: $0["y"]!) }
                completion(points)
            }
        }.resume()
    }

    func drawSkeletonOverlay(_ skeleton: [CGPoint]) {
        overlayView.subviews.forEach { $0.removeFromSuperview() }

        for point in skeleton {
            let dot = UIView(frame: CGRect(x: point.x * overlayView.bounds.width, y: point.y * overlayView.bounds.height, width: 10, height: 10))
            dot.backgroundColor = .green
            dot.layer.cornerRadius = 5
            overlayView.addSubview(dot)
        }
    }
}

