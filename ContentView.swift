//
//  ContentView.swift
//  WorKit
//
//  Created by Vincent von Tersch on 11/20/24.
//
//  CalendarViewController.swift
//  UI_Calendar
//
//  Created by Miguel Guzman on 11/18/24.
//
import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class ContentView: UIViewController {
    
    private var currentDate = Date()
    private var selectedDay: String? = nil
    private let days = ["Sun", "Mon", "Tue", "Wed", "Thurs", "Fri", "Sat"]
    private let weekStackView = UIStackView()
    private let dateLabel = UILabel()
    private let infoLabel = UILabel()
    private let squatCountLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    private var firestoreRef: Firestore!
    private var userId: String = Auth.auth().currentUser?.uid ?? "example_user_id"
    private var workoutHistory: [String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupFirestore()
        setupUI()
        updateDateLabel()
        fetchWorkoutHistory()
        createDayButtons()
    }
    
    private func setupFirestore() {
        firestoreRef = Firestore.firestore()
    }
    
    private func setupUI() {
        // Date Label
        dateLabel.textAlignment = .center
        dateLabel.font = UIFont.boldSystemFont(ofSize: 22)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateLabel)
        
        // Info Box
        let infoBox = UIView()
        infoBox.layer.borderColor = UIColor.black.cgColor
        infoBox.layer.borderWidth = 2
        infoBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoBox)
        
        infoLabel.text = "Select a day to see workout details..."
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoBox.addSubview(infoLabel)
        
        // Squat Count Label
        squatCountLabel.text = "Squats: 0"
        squatCountLabel.textAlignment = .center
        squatCountLabel.font = UIFont.boldSystemFont(ofSize: 18)
        squatCountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(squatCountLabel)
        
        // Week Stack View
        weekStackView.axis = .vertical
        weekStackView.alignment = .fill
        weekStackView.spacing = 10
        weekStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(weekStackView)
        
        // Close Button
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .red
        closeButton.layer.cornerRadius = 20
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        closeButton.addTarget(self, action: #selector(dismissCalendar), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            infoBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoBox.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            infoBox.heightAnchor.constraint(equalToConstant: 100),
            
            infoLabel.leadingAnchor.constraint(equalTo: infoBox.leadingAnchor, constant: 10),
            infoLabel.trailingAnchor.constraint(equalTo: infoBox.trailingAnchor, constant: -10),
            infoLabel.centerYAnchor.constraint(equalTo: infoBox.centerYAnchor),
            
            weekStackView.topAnchor.constraint(equalTo: infoBox.bottomAnchor, constant: 20),
            weekStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weekStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            squatCountLabel.topAnchor.constraint(equalTo: weekStackView.bottomAnchor, constant: 20),
            squatCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        dateLabel.text = formatter.string(from: currentDate)
    }
    
    private func fetchWorkoutHistory() {
        let userDoc = firestoreRef.collection("users").document(userId)
        let workoutsCollection = userDoc.collection("workouts")
        
        workoutsCollection.getDocuments { [weak self] snapshot, error in
            guard let self = self, error == nil, let documents = snapshot?.documents else {
                print("Error fetching workout history: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.workoutHistory = documents.reduce(into: [String: Int]()) { result, document in
                let date = document.documentID
                let squatCount = document.data()["squatCount"] as? Int ?? 0
                result[date] = squatCount
            }
            
            print("Fetched workout history: \(self.workoutHistory)")
            self.createDayButtons()
        }
    }

    private func createDayButtons() {
        weekStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let daysStack = UIStackView()
        daysStack.axis = .horizontal
        daysStack.distribution = .fillEqually
        daysStack.alignment = .center
        daysStack.spacing = 5
        weekStackView.addArrangedSubview(daysStack)

        for day in days {
            let dayLabel = UILabel()
            dayLabel.text = day
            dayLabel.textAlignment = .center
            dayLabel.font = .boldSystemFont(ofSize: 12)
            daysStack.addArrangedSubview(dayLabel)
        }

        let datesStack = UIStackView()
        datesStack.axis = .horizontal
        datesStack.distribution = .fillEqually
        datesStack.alignment = .center
        datesStack.spacing = 5
        weekStackView.addArrangedSubview(datesStack)

        for date in currentWeekDates() {
            let button = UIButton(type: .system)
            button.setTitle(String(date.suffix(2)), for: .normal)
            button.setTitleColor(selectedDay == date ? .black : .white, for: .normal)
            button.backgroundColor = selectedDay == date ? .yellow : .lightGray
            button.layer.cornerRadius = 15
            button.layer.borderWidth = selectedDay == date ? 2 : 0
            button.layer.borderColor = selectedDay == date ? UIColor.black.cgColor : UIColor.clear.cgColor
            button.addTarget(self, action: #selector(selectDay(_:)), for: .touchUpInside)
            datesStack.addArrangedSubview(button)
        }
    }

    private func currentWeekDates() -> [String] {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        
        guard let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: currentDate)?.start else {
            return []
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
            return formatter.string(from: date)
        }
    }
    
    @objc private func selectDay(_ sender: UIButton) {
        guard let displayDate = sender.title(for: .normal),
              let selectedDate = currentWeekDates().first(where: { $0.hasSuffix(displayDate) }) else { return }
        
        selectedDay = selectedDate
        let squatCount = workoutHistory[selectedDate] ?? 0
        squatCountLabel.text = "Squats: \(squatCount)"
        
        createDayButtons()
    }
    
    @objc private func dismissCalendar() {
        dismiss(animated: true, completion: nil)
    }
}
