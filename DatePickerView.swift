//
//  DatePickerView.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import SwiftUI
import SwiftUI

struct DatePickerView: View {
    @Binding var lectureDates: [Date]
    @Binding var isImagePickerPresented: Bool
    @State private var selectedDate: Date = Date()

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Lecture Date")
                .font(.title)
                .bold()

            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

            Button("Confirm Date") {
                lectureDates.append(selectedDate)
                isImagePickerPresented.toggle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
