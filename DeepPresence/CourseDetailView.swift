//
//  CourseDetailView.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import SwiftUI
import Charts

struct CourseDetailView: View {
    var course: Course
    @EnvironmentObject private var studentData: StudentData // Access StudentData
    @State private var lectureImages: [UIImage] = []
    @State private var isImagePickerPresented: Bool = false
    @State private var attendanceData: [Attendance] = [] // Use the Attendance model

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Course Details
                Text(course.name)
                    .font(.title)
                    .bold()
                Text(course.code)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Upload Lecture Image
                Button("Upload Lecture Image") {
                    isImagePickerPresented.toggle()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                // Display Uploaded Images
                if !lectureImages.isEmpty {
                    Text("Uploaded Lecture Images")
                        .font(.headline)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(lectureImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }

                // Enrolled Students
                Text("Enrolled Students")
                    .font(.headline)
                List(studentData.students) { student in
                    VStack(alignment: .leading) {
                        Text(student.name)
                            .font(.headline)
                        Text("Roll No: \(student.rollNo)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 200) // Adjust height as needed

                // Attendance Analytics
                Text("Attendance Analytics")
                    .font(.headline)
                Chart(attendanceData) { data in
                    BarMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Attendance", data.count)
                    )
                }
                .frame(height: 200)
                .padding()
            }
            .padding()
        }
        .navigationTitle("Course Details")
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: Binding<UIImage?>(
                get: { nil },
                set: { image in
                    if let image = image {
                        lectureImages.append(image)
                    }
                }
            ))
        }
        .onAppear {
            loadAttendanceData() // Load attendance data when the view appears
        }
    }

    private func loadAttendanceData() {
        // Simulate attendance data for the chart
        attendanceData = [
            Attendance(date: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 1))!, count: 20),
            Attendance(date: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 2))!, count: 22),
            Attendance(date: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 3))!, count: 18),
            Attendance(date: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 4))!, count: 25),
            Attendance(date: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 5))!, count: 23),
        ]
    }
}
