//
//  LoginView.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var studentData: StudentData
    @State private var loginType: String = ""
    @State private var loginId: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showRegistrationView: Bool = false // New state for showing registration view

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()

                // Role Selection
                Picker("Login As", selection: $loginType) {
                    Text("Instructor").tag("Instructor")
                    Text("TA").tag("TA")
                    Text("Student").tag("Student")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Login ID
                TextField("Login ID (iiitd.ac.in email)", text: $loginId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Password
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Login Button
                Button("Login") {
                    validateLogin()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                // Register as a new user Button
                Button("Register as a new user") {
                    showRegistrationView = true
                }
                .padding()
                .foregroundColor(.blue)

                Spacer()
            }
            .padding()
            .navigationTitle("Deep Presence")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .background(
                Group {
                    if isLoggedIn {
                        if loginType == "Instructor" {
                            NavigationLink(destination: InstructorView().environmentObject(studentData), isActive: $isLoggedIn) {
                                EmptyView()
                            }
                        } else if loginType == "TA" {
                            NavigationLink(destination: TAView().environmentObject(studentData), isActive: $isLoggedIn) {
                                EmptyView()
                            }
                        } else if loginType == "Student" {
                            NavigationLink(destination: StudentView().environmentObject(studentData), isActive: $isLoggedIn) {
                                EmptyView()
                            }
                        }
                    }
                }
            )
            .sheet(isPresented: $showRegistrationView) {
                RegistrationView(loginType: $loginType, loginId: $loginId, password: $password)
                    .environmentObject(studentData)
            }
        }
    }

    private func validateLogin() {
        let email = loginId
        let pass = password

        // Validate email domain
        if !email.hasSuffix("@iiitd.ac.in") {
            alertMessage = "Please use an iiitd.ac.in email address."
            showAlert = true
            return
        }

        // Check if login type is selected
        if loginType.isEmpty {
            alertMessage = "Please select a login type."
            showAlert = true
            return
        }

        // Check if user exists in the database
        if loginType == "Instructor" {
            if let instructor = studentData.instructors.first(where: { $0.email == email }) {
                if instructor.password == pass {
                    isLoggedIn = true
                } else {
                    alertMessage = "Invalid password."
                    showAlert = true
                }
            } else {
                alertMessage = "User does not exist. Please register as a new user."
                showAlert = true
            }
        } else if loginType == "TA" {
            if let ta = studentData.tas.first(where: { $0.email == email }) {
                if ta.password == pass {
                    isLoggedIn = true
                } else {
                    alertMessage = "Invalid password."
                    showAlert = true
                }
            } else {
                alertMessage = "User does not exist. Please register as a new user."
                showAlert = true
            }
        } else if loginType == "Student" {
            if let student = studentData.students.first(where: { $0.email == email }) {
                if student.password == pass {
                    isLoggedIn = true
                } else {
                    alertMessage = "Invalid password."
                    showAlert = true
                }
            } else {
                alertMessage = "User does not exist. Please register as a new user."
                showAlert = true
            }
        }
    }
}
