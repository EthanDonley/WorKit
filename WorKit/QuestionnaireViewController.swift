//
//  QuestionnaireViewController.swift
//  WorKit
//
//  Created by Vincent von Tersch on 10/9/24.
//l

import Foundation
import UIKit

class QuestionnaireViewController: UIViewController {

    // Create the UILabel, UISegmentedControl, and UIButton as class properties
    var questionLabel1: UILabel!
    var segmentedControl1: UISegmentedControl!
    
    var questionLabel2: UILabel!
    var segmentedControl2: UISegmentedControl!
    
    var questionLabel3: UILabel!
    var segmentedControl3: UISegmentedControl!
    
    var questionLabel4: UILabel!
    var segmentedControl4: UISegmentedControl!
    
    var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Call the function to set up the UI elements
        setupUI()
    }
    
    func setupUI() {
        // Set background color
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Question 1
        questionLabel1 = UILabel()
        questionLabel1.text = "What is your main goal?"
        questionLabel1.textAlignment = .center
        questionLabel1.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        questionLabel1.textColor = UIColor.white
        questionLabel1.translatesAutoresizingMaskIntoConstraints = false  // Enable Auto Layout
        view.addSubview(questionLabel1)
        
        segmentedControl1 = UISegmentedControl(items: ["Lose weight", "Bulk up", "Improve Cardio"])
        segmentedControl1.selectedSegmentIndex = 0
        segmentedControl1.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        segmentedControl1.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        segmentedControl1.translatesAutoresizingMaskIntoConstraints = false  // Enable Auto Layout
        view.addSubview(segmentedControl1)
        
        // Question 2
        questionLabel2 = UILabel()
        questionLabel2.text = "How many times a week do you exercise?"
        questionLabel2.textAlignment = .center
        questionLabel2.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        questionLabel2.textColor = UIColor.white
        questionLabel2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionLabel2)

        segmentedControl2 = UISegmentedControl(items: ["1-2", "3-4", "5-6", "Every day"])
        segmentedControl2.selectedSegmentIndex = 0
        segmentedControl2.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        segmentedControl2.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        segmentedControl2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl2)

        // Question 3
        questionLabel3 = UILabel()
        questionLabel3.text = "How many hours per day are you able to work out?"
        questionLabel3.textAlignment = .center
        questionLabel3.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        questionLabel3.textColor = UIColor.white
        questionLabel3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionLabel3)

        segmentedControl3 = UISegmentedControl(items: ["0.5 - 1 hour", "1 - 2 hours", "2 - 3 hours", "3+ hours"])
        segmentedControl3.selectedSegmentIndex = 0
        segmentedControl3.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        segmentedControl3.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        segmentedControl3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl3)
        
        // Question 4
        questionLabel4 = UILabel()
        questionLabel4.text = "Do you have access to weights?"
        questionLabel4.textAlignment = .center
        questionLabel4.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        questionLabel4.textColor = UIColor.white
        questionLabel4.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionLabel4)
        
        segmentedControl4 = UISegmentedControl(items: ["Yes", "No"])
        segmentedControl4.selectedSegmentIndex = 0
        segmentedControl4.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        segmentedControl4.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        segmentedControl4.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl4)
        
        // Initialize the UIButton
        submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(self, action: #selector(submitAnswers), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false  // Enable Auto Layout
        view.addSubview(submitButton)
        
        // Set up Auto Layout constraints for the UILabel, UISegmentedControl, and UIButton
        setupConstraints()
    }
    
    func setupConstraints() {
        // Constraints for Question 1
        NSLayoutConstraint.activate([
            questionLabel1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionLabel1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            segmentedControl1.topAnchor.constraint(equalTo: questionLabel1.bottomAnchor, constant: 20),
            segmentedControl1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        // Constraints for Question 2
        NSLayoutConstraint.activate([
            questionLabel2.topAnchor.constraint(equalTo: segmentedControl1.bottomAnchor, constant: 20),
            questionLabel2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            segmentedControl2.topAnchor.constraint(equalTo: questionLabel2.bottomAnchor, constant: 20),
            segmentedControl2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        // Constraints for Question 3
        NSLayoutConstraint.activate([
            questionLabel3.topAnchor.constraint(equalTo: segmentedControl2.bottomAnchor, constant: 20),
            questionLabel3.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel3.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            segmentedControl3.topAnchor.constraint(equalTo: questionLabel3.bottomAnchor, constant: 20),
            segmentedControl3.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl3.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        // Constraints for Question 4
        NSLayoutConstraint.activate([
            questionLabel4.topAnchor.constraint(equalTo: segmentedControl3.bottomAnchor, constant: 20),
            questionLabel4.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel4.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            segmentedControl4.topAnchor.constraint(equalTo: questionLabel4.bottomAnchor, constant: 20),
            segmentedControl4.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl4.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        // Constraints for Submit Button
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: segmentedControl4.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func submitAnswers() {
        // Retrieve answers from each segmented control
        let answer1 = segmentedControl1.titleForSegment(at: segmentedControl1.selectedSegmentIndex)
        let answer2 = segmentedControl2.titleForSegment(at: segmentedControl2.selectedSegmentIndex)
        let answer3 = segmentedControl3.titleForSegment(at: segmentedControl3.selectedSegmentIndex)
        let answer4 = segmentedControl4.titleForSegment(at: segmentedControl4.selectedSegmentIndex)

        print("Answers submitted: \(answer1 ?? ""), \(answer2 ?? ""), \(answer3 ?? ""), \(answer4 ?? "")")
        
        // Handle submission logic here
        self.dismiss(animated: true, completion: nil)
    }
}
