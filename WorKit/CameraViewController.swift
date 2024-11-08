import AVFoundation
import UIKit
import MLKitVision
import MLKitPoseDetection

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var lastFrameTime: Date = Date(timeIntervalSince1970: 0)
    
    private lazy var poseDetector: PoseDetector = {
        let options = PoseDetectorOptions()
        options.detectorMode = .singleImage // Single-image mode for screenshots
        return PoseDetector.poseDetector(options: options)
    }()
    
    private var overlayLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        // Set up front camera
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Failed to get front camera")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print("Error accessing camera: \(error)")
            return
        }

        // Set up video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraFrameProcessingQueue"))
        captureSession.addOutput(videoOutput)
        
        // Display camera feed
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        // Add overlay layer for skeleton
        overlayLayer.frame = view.bounds
        overlayLayer.strokeColor = UIColor.green.cgColor
        overlayLayer.lineWidth = 3.0
        overlayLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(overlayLayer)

        // Start capture session
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    // Capture frames, convert to UIImage, and process for pose analysis
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentTime = Date()
        
        guard currentTime.timeIntervalSince(lastFrameTime) > 1.0 else { return }
        lastFrameTime = currentTime

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Use OpenCVWrapper to create UIImage
        if let imageForMLKit = OpenCVWrapper.image(from: pixelBuffer), imageForMLKit.cgImage != nil {
            let visionImage = VisionImage(image: imageForMLKit)
            visionImage.orientation = .up  // Adjust orientation as needed

            poseDetector.process(visionImage) { [weak self] result, error in
                guard let self = self, let poses = result as? [Pose], let pose = poses.first, error == nil else {
                    print("Pose detection error: \(String(describing: error))")
                    return
                }
                DispatchQueue.main.async {
                    self.updateSkeletonOverlay(pose)
                }
            }
        } else {
            print("Invalid image: UIImage could not be created or has NULL CGImage")
        }
    }
    // Update skeleton overlay
    func updateSkeletonOverlay(_ pose: Pose) {
        let path = UIBezierPath()
        
        // Draw each joint as a green circle and connect with lines
        for landmark in pose.landmarks {
            let point = CGPoint(
                x: landmark.position.x * view.bounds.width,
                y: (1 - landmark.position.y) * view.bounds.height
            )
            path.move(to: point)
            path.addArc(withCenter: point, radius: 5, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        }

        // Connect key joints (example: connecting shoulders and elbows)
        let connections: [(PoseLandmarkType, PoseLandmarkType)] = [
            (.leftShoulder, .leftElbow),
            (.leftElbow, .leftWrist),
            (.rightShoulder, .rightElbow),
            (.rightElbow, .rightWrist),
            (.leftHip, .leftKnee),
            (.leftKnee, .leftAnkle),
            (.rightHip, .rightKnee),
            (.rightKnee, .rightAnkle),
            (.leftShoulder, .rightShoulder),
            (.leftHip, .rightHip)
        ]
        
        for (startType, endType) in connections {
            let startLandmark = pose.landmark(ofType: startType)
            let endLandmark = pose.landmark(ofType: endType)
            
            let startPoint = CGPoint(
                x: startLandmark.position.x * view.bounds.width,
                y: (1 - startLandmark.position.y) * view.bounds.height
            )
            let endPoint = CGPoint(
                x: endLandmark.position.x * view.bounds.width,
                y: (1 - endLandmark.position.y) * view.bounds.height
            )
            
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        
        overlayLayer.path = path.cgPath
    }
}

