//
//  CalendarViewController.swift
//  UI_Calendar
//
//  Created by Miguel Guzman on 11/18/24.
//

import UIKit

class CalendarViewController: UIViewController {
    
    private var currentDate = Date()
    private var selectedDay: String? = nil
    private let days = ["Sun", "Mon", "Tue", "Wed", "Thurs", "Fri", "Sat"]
    private let weekStackView = UIStackView()
    private let dateLabel = UILabel()
    private let infoLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        updateDateLabel()
        createDayButtons()
    }
    
    private func setupUI() {
        // Info Box
        let infoBox = UIView()
        infoBox.layer.borderColor = UIColor.black.cgColor
        infoBox.layer.borderWidth = 2
        infoBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoBox)
        
        infoLabel.text = "Insert information here from Firebase..."
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoBox.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            infoBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoBox.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            infoBox.heightAnchor.constraint(equalToConstant: 100),
            
            infoLabel.leadingAnchor.constraint(equalTo: infoBox.leadingAnchor, constant: 10),
            infoLabel.trailingAnchor.constraint(equalTo: infoBox.trailingAnchor, constant: -10),
            infoLabel.centerYAnchor.constraint(equalTo: infoBox.centerYAnchor)
        ])
        
        // Current Week Button
        let currentWeekButton = UIButton(type: .system)
        currentWeekButton.setTitle("Current Week", for: .normal)
        currentWeekButton.setTitleColor(.white, for: .normal)
        currentWeekButton.backgroundColor = .red
        currentWeekButton.layer.cornerRadius = 4
        currentWeekButton.layer.borderWidth = 2
        currentWeekButton.layer.borderColor = UIColor.black.cgColor
        currentWeekButton.translatesAutoresizingMaskIntoConstraints = false
        currentWeekButton.addTarget(self, action: #selector(goToCurrentWeek), for: .touchUpInside)
        view.addSubview(currentWeekButton)
        
        // Date Label and Navigation
        let navStackView = UIStackView()
        navStackView.axis = .horizontal
        navStackView.distribution = .equalSpacing
        navStackView.alignment = .center
        navStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navStackView)
        
        let prevButton = UIButton(type: .system)
        prevButton.setTitle("◀︎", for: .normal)
        prevButton.titleLabel?.font = UIFont.systemFont(ofSize: 24) // Larger font for bigger size
        prevButton.addTarget(self, action: #selector(goToPreviousWeek), for: .touchUpInside)
        
        let nextButton = UIButton(type: .system)
        nextButton.setTitle("▶︎", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 24) // Larger font for bigger size
        nextButton.addTarget(self, action: #selector(goToNextWeek), for: .touchUpInside)
        
        dateLabel.textAlignment = .center
        
        navStackView.addArrangedSubview(prevButton)
        navStackView.addArrangedSubview(dateLabel)
        navStackView.addArrangedSubview(nextButton)
        
        // Days Grid
        weekStackView.axis = .vertical
        weekStackView.alignment = .fill
        weekStackView.spacing = 10
        weekStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(weekStackView)
        
        NSLayoutConstraint.activate([
            currentWeekButton.topAnchor.constraint(equalTo: infoBox.bottomAnchor, constant: 20),
            currentWeekButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentWeekButton.widthAnchor.constraint(equalToConstant: 120),
            currentWeekButton.heightAnchor.constraint(equalToConstant: 30),
            
            navStackView.topAnchor.constraint(equalTo: currentWeekButton.bottomAnchor, constant: 20),
            navStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            weekStackView.topAnchor.constraint(equalTo: navStackView.bottomAnchor, constant: 20),
            weekStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weekStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let monthYear = formatter.string(from: currentDate)
        
        let calendar = Calendar.current
        let weekOfMonth = calendar.component(.weekOfMonth, from: currentDate)
        
        let ordinalFormatter = NumberFormatter()
        ordinalFormatter.numberStyle = .ordinal
        let weekOrdinal = ordinalFormatter.string(from: NSNumber(value: weekOfMonth)) ?? "\(weekOfMonth)"
        
        dateLabel.text = "\(weekOrdinal) week of \(monthYear)"
    }
    
    private func createDayButtons() {
        weekStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let daysStack = UIStackView()
        daysStack.axis = .horizontal
        daysStack.distribution = .fillEqually
        daysStack.alignment = .center
        daysStack.spacing = 5
        
        for day in days {
            let dayLabel = UILabel()
            dayLabel.text = day
            dayLabel.textAlignment = .center
            dayLabel.font = .boldSystemFont(ofSize: 12)
            daysStack.addArrangedSubview(dayLabel)
        }
        weekStackView.addArrangedSubview(daysStack)
        
        let datesStack = UIStackView()
        datesStack.axis = .horizontal
        datesStack.distribution = .fillEqually
        datesStack.alignment = .center
        datesStack.spacing = 5
        
        for date in currentWeekDates() {
            let button = UIButton(type: .system)
            button.setTitle(date, for: .normal)
            button.setTitleColor(selectedDay == date ? .black : .white, for: .normal)
            button.backgroundColor = selectedDay == date ? .yellow : .lightGray
            button.layer.cornerRadius = 15
            button.layer.borderWidth = selectedDay == date ? 2 : 0
            button.layer.borderColor = selectedDay == date ? UIColor.black.cgColor : UIColor.clear.cgColor
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 30).isActive = true
            button.widthAnchor.constraint(equalToConstant: 30).isActive = true
            button.addTarget(self, action: #selector(selectDay(_:)), for: .touchUpInside)
            datesStack.addArrangedSubview(button)
        }
        weekStackView.addArrangedSubview(datesStack)
    }
    
    private func currentWeekDates() -> [String] {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        guard let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: currentDate)?.start else {
            return []
        }
        return (0..<7).compactMap { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
            let dayNumber = calendar.component(.day, from: date ?? Date())
            return "\(dayNumber)"
        }
    }
    
    @objc private func goToPreviousWeek() {
        currentDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate) ?? currentDate
        updateDateLabel()
        createDayButtons()
    }
    
    @objc private func goToNextWeek() {
        currentDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
        updateDateLabel()
        createDayButtons()
    }
    
    @objc private func goToCurrentWeek() {
        currentDate = Date()
        updateDateLabel()
        createDayButtons()
    }
    
    @objc private func selectDay(_ sender: UIButton) {
        selectedDay = sender.title(for: .normal)
        createDayButtons()
    }
}
