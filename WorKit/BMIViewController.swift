//
//  BMIViewController.swift
//  WorKit
//
//  Created by Ethan Donley on 9/20/24.
//

import UIKit

protocol BMIViewControllerDelegate: AnyObject {
    func bmiViewControllerDidFinish(_ controller: BMIViewController)
}

class BMIViewController: UIViewController {
    
    weak var delegate: BMIViewControllerDelegate?  // Delegate to pass data back

    let weightTextField = UITextField()
    let feetTextField = UITextField()
    let inchesTextField = UITextField()
    let resultLabel = UILabel()
    let calculateButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemBackground
        title = "BMI Calculator"
        
        // Add UI elements for the BMI calculator
        setupUI()
    }
    
    func setupUI() {
        // Configure Weight TextField
        configureTextField(weightTextField, placeholder: "Enter your weight (lbs)")
        
        // Configure Feet TextField
        configureTextField(feetTextField, placeholder: "Enter your height - feet")
        
        // Configure Inches TextField
        configureTextField(inchesTextField, placeholder: "Enter your height - inches")
        
        // Configure Calculate Button
        calculateButton.setTitle("Calculate BMI", for: .normal)
        calculateButton.backgroundColor = UIColor.systemBlue
        calculateButton.setTitleColor(.white, for: .normal)
        calculateButton.layer.cornerRadius = 10
        calculateButton.addTarget(self, action: #selector(calculateBMI), for: .touchUpInside)
        calculateButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calculateButton)
        
        // Configure Result Label
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.boldSystemFont(ofSize: 18)
        resultLabel.numberOfLines = 0
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultLabel)

        // Configure Save Button
        saveButton.setTitle("Save BMI", for: .normal)
        saveButton.backgroundColor = UIColor.systemGreen
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.isHidden = true
        saveButton.addTarget(self, action: #selector(saveBMI), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        // Set up Constraints
        NSLayoutConstraint.activate([
            weightTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            weightTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weightTextField.widthAnchor.constraint(equalToConstant: 250),
            
            feetTextField.topAnchor.constraint(equalTo: weightTextField.bottomAnchor, constant: 20),
            feetTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feetTextField.widthAnchor.constraint(equalToConstant: 250),
            
            inchesTextField.topAnchor.constraint(equalTo: feetTextField.bottomAnchor, constant: 20),
            inchesTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inchesTextField.widthAnchor.constraint(equalToConstant: 250),
            
            calculateButton.topAnchor.constraint(equalTo: inchesTextField.bottomAnchor, constant: 30),
            calculateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            calculateButton.widthAnchor.constraint(equalToConstant: 200),
            calculateButton.heightAnchor.constraint(equalToConstant: 50),
            
            resultLabel.topAnchor.constraint(equalTo: calculateButton.bottomAnchor, constant: 30),
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.widthAnchor.constraint(equalToConstant: 300),
            
            saveButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Helper function to configure text fields
    func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
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

        // Notify delegate that the BMI calculation is complete
        delegate?.bmiViewControllerDidFinish(self)

        // Dismiss the modal pop-up window
        dismiss(animated: true, completion: nil)
    }

}

