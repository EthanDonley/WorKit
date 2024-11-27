//
//  ContentView.swift
//  UI_Calendar
//
//  Created by Miguel Guzman on 11/13/24.
//

import SwiftUI

// Custom Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))         // Top middle
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))      // Bottom left
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))      // Bottom right
        path.closeSubpath()
        return path
    }
}

struct ContentView: View {
    @State private var currentDate = Date()
    
    let minimumWidth: CGFloat = 100
    let maximumWidth: CGFloat = 330
    let minimumHeight: CGFloat = 10
    let maximumHeight: CGFloat = 100
    let days = ["Sun", "Mon", "Tue", "Wed", "Thurs", "Fri", "Sat"]
    
    // Function to format date as "Xth Week of Month, 20XX"
    func formattedDate() -> String {
        let calendar = Calendar.current
        
        // Get week number of the month
        let weekOfMonth = calendar.component(.weekOfMonth, from: currentDate)
        
        // Get month and year
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: currentDate)
        
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: currentDate)
        
        // Determine ordinal suffix for week number
        let ordinalFormatter = NumberFormatter()
        ordinalFormatter.numberStyle = .ordinal
        let weekOrdinal = ordinalFormatter.string(from: NSNumber(value: weekOfMonth)) ?? "\(weekOfMonth)"
        
        return "\(weekOrdinal) Week of \(month), \(year)"
    }
    
    // Function to get the dates for each day in the current week
    func currentWeekDates() -> [String] {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Sunday is the first day of the week
        
        // Find the start of the current week
        let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: currentDate)?.start ?? currentDate
        
        // Generate dates for the current week
        var weekDates: [String] = []
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let dayNumber = calendar.component(.day, from: day)
                weekDates.append("\(dayNumber)") // Append day number as a string
            }
        }
        
        return weekDates
    }
    
    // Function to go to the previous week
    func goToPreviousWeek() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    // Function to go to the next week
    func goToNextWeek() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // Top navigation with arrows and formatted date
            HStack {
                // Left arrow button
                Button(action: goToPreviousWeek) {
                    Triangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.teal]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 30, height: 30)
                        .rotationEffect(.degrees(-90))
                }
                
                Spacer()
                
                // Display formatted date
                Text(formattedDate())
                    .padding(.horizontal)
                
                Spacer()
                
                // Right arrow button
                Button(action: goToNextWeek) {
                    Triangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.teal, Color.green]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 30, height: 30)
                        .rotationEffect(.degrees(90))
                }
            }
            .padding()
            
            // Calendar section with vertical lines, day labels, and day numbers
            ZStack {
                // Rectangle for calendar
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(minWidth: minimumWidth, maxWidth: maximumWidth, minHeight: minimumHeight, maxHeight: maximumHeight)
                
                GeometryReader { geometry in
                    let lineCount = 6
                    let spacing = geometry.size.width / CGFloat(lineCount + 1)
                    
                    // Get the day numbers for the current week
                    let weekDates = currentWeekDates()
                    
                    // Draw vertical lines and add day labels with day numbers
                    ForEach(0..<lineCount + 1, id: \.self) { index in
                        let xPosition = spacing * CGFloat(index)
                        
                        // Vertical line
                        if index < lineCount {
                            Path { path in
                                path.move(to: CGPoint(x: xPosition + spacing, y: 0))
                                path.addLine(to: CGPoint(x: xPosition + spacing, y: geometry.size.height))
                            }
                            .stroke(Color.black, lineWidth: 1)
                        }
                        
                        // Day label (above the horizontal line)
                        Text(days[index])
                            .font(.system(size: 12, weight: .bold))
                            .position(x: xPosition + spacing / 2, y: geometry.size.height / 6)
                        
                        // Day number with circle background (centered below the horizontal line)
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2)) // Light gray circle background
                                .frame(width: 30, height: 30) // Adjust size as needed
                            
                            Text(weekDates[index])
                                .font(.system(size: 12))
                        }
                        .position(x: xPosition + spacing / 2, y: geometry.size.height / 2 + 15) // Adjust the Y-position slightly to center it below the line
                    }
                    
                    // Horizontal line in the top-middle
                    Path { path in
                        let yPosition = geometry.size.height / 3
                        path.move(to: CGPoint(x: 0, y: yPosition))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: yPosition))
                    }
                    .stroke(Color.black, lineWidth: 1)
                }
            }
            .frame(minWidth: minimumWidth, maxWidth: maximumWidth, minHeight: minimumHeight, maxHeight: maximumHeight)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
