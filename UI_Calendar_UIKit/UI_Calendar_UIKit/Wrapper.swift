//
//  Wrapper.swift
//  UI_Calendar
//
//  Created by Miguel Guzman on 11/18/24.
//

import SwiftUI

struct CalendarViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CalendarViewController {
        return CalendarViewController()
    }

    func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
        // Leave empty as no updates are needed for this example
    }
}
