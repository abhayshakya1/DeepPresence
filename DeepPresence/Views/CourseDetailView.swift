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
    @StateObject private var viewModel = CourseViewModel() // Use the ViewModel
    @State private var lectureImages: [UIImage] = []
    @State private var isImagePickerPresented: Bool = false
    @State private var isDatePickerPresented: Bool = false
    @State private var lectureDates: [Date] = []
    @State private var selectedDate: Date? = nil
    @State private var attendanceData: [Attendance] = [] // Use the Attendance model
    @State private var tas: [TA] = [
        TA(id: UUID(), name: "Puneet Singh Bhooi", email: "puneetb@iiitd.ac.in", password: "", hasAccess: false),
        TA(id: UUID(), name: "Drishya Uniyal", email: "drishyau@iiitd.ac.in", password: "", hasAccess: false),
        TA(id: UUID(), name: "Suryaka Suresh", email: "suryakas@iiitd.ac.in", password: "", hasAccess: false),
        TA(id: UUID(), name: "Aman Chauhan", email: "aman23015@iiitd.ac.in", password: "", hasAccess: false),
        TA(id: UUID(), name: "Shubham Kale", email: "shubham23094@iiitd.ac.in", password: "", hasAccess: false),
        TA(id: UUID(), name: "Shreyas Rajendra Gore", email: "shreyas24087@iiitd.ac.in", password: "", hasAccess: false),
        TA(id: UUID(), name: "Lakshya", email: "lakshya21262@iiitd.ac.in", password: "", hasAccess: false),
    ] // Sample TAs
    @State private var selectedTA: TA? = nil
    @State private var students: [Student] // Mutable copy of course.students

    init(course: Course) {
        self.course = course
        self._students = State(initialValue: course.students)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Course Details
                Text(course.courseName)
                    .font(.title)
                    .bold()
                Text(course.courseId)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Dropdown for Lecture Dates
                if !lectureDates.isEmpty {
                    Picker("Select Lecture Date", selection: $selectedDate) {
                        ForEach(lectureDates, id: \.self) { date in
                            Text(dateFormatter.string(from: date))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }

                // Upload Lecture Image
                Button("Upload Lecture Image") {
                    isDatePickerPresented.toggle()
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

                // TAs Dropdown
                Text("Teaching Assistants")
                    .font(.headline)
                Picker("Select TA", selection: $selectedTA) {
                    ForEach(tas, id: \.self) { ta in
                        Text(ta.name).tag(ta as TA?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                // Grant Access to TA
                if let selectedTA = selectedTA {
                    Toggle("Grant Access to \(selectedTA.name)", isOn: Binding(
                        get: { selectedTA.hasAccess },
                        set: { newValue in
                            if let index = tas.firstIndex(where: { $0.id == selectedTA.id }) {
                                tas[index].hasAccess = newValue
                            }
                        }
                    ))
                    .padding()
                }

                // Enrolled Students
                Text("Enrolled Students")
                    .font(.headline)
                List {
                    ForEach($students) { $student in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(student.name)
                                    .font(.headline)
                                Text("Email: \(student.email)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if selectedTA?.hasAccess == true {
                                Toggle("Present", isOn: $student.isPresent)
                            }
                        }
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
        .sheet(isPresented: $isDatePickerPresented) {
            DatePickerView(lectureDates: $lectureDates, isImagePickerPresented: $isImagePickerPresented)
        }
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
            viewModel.fetchCourses() // Fetch courses when the view appears
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

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
