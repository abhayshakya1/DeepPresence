//
//  InstructorView.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import SwiftUI

struct InstructorView: View {
    @EnvironmentObject private var studentData: StudentData // Access StudentData
    @State private var isAddingCourse: Bool = false
    @State private var newCourseName: String = ""
    @State private var newCourseCode: String = ""

    var body: some View {
        NavigationView {
            VStack {
                if studentData.courses.isEmpty {
                    Text("No ongoing courses.")
                        .font(.title2)
                        .padding()

                    Button("Add Course") {
                        isAddingCourse.toggle()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
                    List {
                        ForEach(studentData.courses) { course in
                            NavigationLink(destination: CourseDetailView(course: course).environmentObject(studentData)) {
                                VStack(alignment: .leading) {
                                    Text(course.name)
                                        .font(.headline)
                                    Text(course.code)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: deleteCourse)
                    }
                    .navigationTitle("Ongoing Courses")
                }

                if !studentData.courses.isEmpty {
                    Button("Add Another Course") {
                        isAddingCourse.toggle()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .sheet(isPresented: $isAddingCourse) {
                VStack(spacing: 20) {
                    Text("Add New Course")
                        .font(.title)
                        .bold()

                    TextField("Course Name", text: $newCourseName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    TextField("Course Code", text: $newCourseCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Save Course") {
                        saveCourse()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
    }

    private func saveCourse() {
        let newCourse = Course(id: UUID(), name: newCourseName, code: newCourseCode)
        studentData.courses.append(newCourse) // Modify the @Published property
        isAddingCourse = false
        newCourseName = ""
        newCourseCode = ""
    }

    private func deleteCourse(at offsets: IndexSet) {
        studentData.courses.remove(atOffsets: offsets) // Modify the @Published property
    }
}
