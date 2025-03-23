//
//  RegistrationView.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/20/25.
//
import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject private var studentData: StudentData
    @Binding var loginType: String
    @Binding var loginId: String
    @Binding var password: String
    @State private var name: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var selectedRole: String = "" // New state for role selection

    var body: some View {
        VStack(spacing: 20) {
            Text("Register as a new user")
                .font(.title)
                .bold()

            // Role Selection
            Picker("Register As", selection: $selectedRole) {
                Text("Instructor").tag("Instructor")
                Text("TA").tag("TA")
                Text("Student").tag("Student")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            TextField("Full Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Email", text: $loginId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disabled(true) // Email is pre-filled and cannot be changed

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Register") {
                registerUser()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Registration Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            selectedRole = loginType // Set the selected role based on the login type
        }
    }

    private func registerUser() {
        if name.isEmpty || password.isEmpty {
            alertMessage = "Name and password cannot be empty."
            showAlert = true
            return
        }

        if selectedRole == "Instructor" {
            let newInstructor = Instructor(
                id: UUID(),
                name: name,
                email: loginId,
                password: password,
                courses: []
            )
            studentData.instructors.append(newInstructor)
        } else if selectedRole == "TA" {
            let newTA = TA(
                id: UUID(),
                name: name,
                email: loginId,
                password: password,
                hasAccess: false
            )
            studentData.tas.append(newTA)
        } else if selectedRole == "Student" {
            let newStudent = Student(
                id: UUID(),
                name: name,
                rollNo: "", // Add roll number if needed
                email: loginId,
                password: password,
                course: "", // Add course if needed
                instructor: "", // Add instructor if needed
                isPresent: false
            )
            studentData.students.append(newStudent)
        }

        // Simulate successful registration
        alertMessage = "Registration successful. Please log in."
        showAlert = true
    }
}
