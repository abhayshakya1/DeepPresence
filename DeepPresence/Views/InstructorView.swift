//
//  InstructorView.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import SwiftUI

struct InstructorView: View {
    @State private var courses: [Course] = []
    @State private var isAddingCourse: Bool = false
    @State private var newCourseName: String = ""
    @State private var newCourseCode: String = ""
    @State private var newSemester: String = ""

    var body: some View {
        NavigationView {
            VStack {
                if courses.isEmpty {
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
                        ForEach(courses) { course in
                            NavigationLink(destination: CourseDetailView(course: course)) {
                                VStack(alignment: .leading) {
                                    Text(course.courseName)
                                        .font(.headline)
                                    Text(course.courseId)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(course.semester)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: deleteCourse)
                    }
                    .navigationTitle("Ongoing Courses")
                }

                if !courses.isEmpty {
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

                    TextField("Semester", text: $newSemester)
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
        let newCourse = Course(
            id: UUID(),
            courseName: newCourseName,
            courseId: newCourseCode,
            semester: newSemester,
            instructorEmail: "", // Add instructor email if needed
            instructorName: "", // Add instructor name if needed
            students: [],
            enrolledStudentsCount: 0
        )
        courses.append(newCourse)
        isAddingCourse = false
        newCourseName = ""
        newCourseCode = ""
        newSemester = ""
    }

    private func deleteCourse(at offsets: IndexSet) {
        courses.remove(atOffsets: offsets)
    }
}
