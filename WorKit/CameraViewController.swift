//
//  CameraViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 10/10/24.
//

import AVFoundation
import UIKit

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        // Set up the front (selfie) camera
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Failed to get the front camera device")
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
        
        // Run startRunning on a background thread to avoid blocking the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
        
        // Display the camera feed
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
    }
    
    // Capture frames
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // Use the renamed method: 'image(from:)'
        if let image = OpenCVWrapper.image(from: pixelBuffer) {
            // Process the UIImage as needed
            DispatchQueue.main.async {
                // Display the image, update UI, or process further
                let imageView = UIImageView(image: image)
                imageView.frame = self.view.bounds
                self.view.addSubview(imageView)
            }
        }
    }
}


