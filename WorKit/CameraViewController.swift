import AVFoundation
import UIKit
import FirebaseStorage
import QuickPoseCore
import QuickPoseCamera

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var lastFrameTime: Date = Date(timeIntervalSince1970: 0)
    
    // QuickPose Processor for detecting poses
    private var quickPoseProcessor: QuickPoseProcessor!
    private var overlayLayer = CAShapeLayer() // Layer for rendering skeleton

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupOverlayLayer()
        setupQuickPose()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Failed to access front camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print("Error accessing camera: \(error)")
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraFrameProcessingQueue"))
        captureSession.addOutput(videoOutput)
        
        // Display the camera feed
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
    }
    
    private func setupOverlayLayer() {
        overlayLayer.frame = view.bounds
        overlayLayer.strokeColor = UIColor.green.cgColor
        overlayLayer.lineWidth = 3.0
        overlayLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(overlayLayer)
    }

    private func setupQuickPose() {
        quickPoseProcessor = QuickPoseProcessor(
            model: .blazePose,
            options: [.realTime],
            sdkKey: "01JCWF5YEDVBWV08ZJ1XNQF4HB" // Replace with your SDK key
        )
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentTime = Date()
        guard currentTime.timeIntervalSince(lastFrameTime) > 1.0 else { return }
        lastFrameTime = currentTime

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Error: Could not retrieve pixel buffer.")
            return
        }

        // Process the frame using QuickPose
        quickPoseProcessor.processFrame(pixelBuffer: pixelBuffer) { [weak self] (poses: [DetectedPose]) in
            guard let self = self, let pose = poses.first else {
                print("No pose detected.")
                return
            }
            DispatchQueue.main.async {
                self.drawSkeleton(for: pose)
            }
        }
    }

    private func drawSkeleton(for pose: DetectedPose) {
        overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() } // Clear old skeleton drawings
        
        let path = UIBezierPath()

        // Draw landmarks as circles
        for landmark in pose.landmarks {
            let point = CGPoint(
                x: landmark.x * view.bounds.width,
                y: (1 - landmark.y) * view.bounds.height
            )
            path.move(to: point)
            path.addArc(withCenter: point, radius: 4, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        }
        
        overlayLayer.path = path.cgPath
    }
}

