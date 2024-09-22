//
//  BMIViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//

import UIKit

class BMIViewController: UIViewController {
    
    let weightTextField = UITextField()
    let feetTextField = UITextField()
    let inchesTextField = UITextField()
    let resultLabel = UILabel()
    let calculateButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "BMI Calculator"
        
        // Add UI elements for the BMI calculator
        setupUI()
    }
    
    func setupUI() {
        // Configure Weight TextField
        weightTextField.placeholder = "Enter your weight (lbs)"
        weightTextField.borderStyle = .roundedRect
        weightTextField.keyboardType = .decimalPad
        weightTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(weightTextField)
        
        // Configure Feet TextField
        feetTextField.placeholder = "Enter your height - feet"
        feetTextField.borderStyle = .roundedRect
        feetTextField.keyboardType = .decimalPad
        feetTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(feetTextField)
        
        // Configure Inches TextField
        inchesTextField.placeholder = "Enter your height - inches"
        inchesTextField.borderStyle = .roundedRect
        inchesTextField.keyboardType = .decimalPad
        inchesTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inchesTextField)
        
        // Configure Calculate Button
        calculateButton.setTitle("Calculate BMI", for: .normal)
        calculateButton.addTarget(self, action: #selector(calculateBMI), for: .touchUpInside)
        calculateButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calculateButton)
        
        // Configure Result Label
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultLabel)

        // Configure Save Button
        saveButton.setTitle("Save BMI", for: .normal)
        saveButton.isHidden = true
        saveButton.addTarget(self, action: #selector(saveBMI), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        // Set up Constraints
        NSLayoutConstraint.activate([
            weightTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            weightTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weightTextField.widthAnchor.constraint(equalToConstant: 200),
            
            feetTextField.topAnchor.constraint(equalTo: weightTextField.bottomAnchor, constant: 20),
            feetTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feetTextField.widthAnchor.constraint(equalToConstant: 200),
            
            inchesTextField.topAnchor.constraint(equalTo: feetTextField.bottomAnchor, constant: 20),
            inchesTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inchesTextField.widthAnchor.constraint(equalToConstant: 200),
            
            calculateButton.topAnchor.constraint(equalTo: inchesTextField.bottomAnchor, constant: 20),
            calculateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            resultLabel.topAnchor.constraint(equalTo: calculateButton.bottomAnchor, constant: 20),
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.widthAnchor.constraint(equalToConstant: 300),
            
            saveButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func calculateBMI() {
        guard let weight = Double(weightTextField.text ?? ""),
              let feet = Double(feetTextField.text ?? ""),
              let inches = Double(inchesTextField.text ?? "") else {
            resultLabel.text = "Invalid input"
            return
        }
        
        let totalInches = (feet * 12) + inches
        let bmi = (weight / (totalInches * totalInches)) * 703
        resultLabel.text = String(format: "Your BMI is: %.2f", bmi)
        
        // Show Save Button after BMI is calculated
        saveButton.isHidden = false
    }
    
    @objc func saveBMI() {
        guard let bmiText = resultLabel.text, !bmiText.isEmpty else {
            return
        }
        
        // Extract BMI value from the label
        let bmiValue = bmiText.replacingOccurrences(of: "Your BMI is: ", with: "")
        
        // Save BMI to UserDefaults (or use Firebase if preferred)
        UserDefaults.standard.set(bmiValue, forKey: "userBMI")
        
        // Dismiss the modal and navigate to HomeViewController after saving BMI
        dismiss(animated: true) {
            // Get the current active scene
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                if let window = scene.windows.first(where: { $0.isKeyWindow }) {
                    let homeVC = HomeViewController()
                    let navController = UINavigationController(rootViewController: homeVC)
                    navController.modalPresentationStyle = .fullScreen
                    window.rootViewController = navController
                    window.makeKeyAndVisible()
                }
            }
        }
    }
}
