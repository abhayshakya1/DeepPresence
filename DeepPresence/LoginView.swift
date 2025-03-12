//
//  LoginView.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var studentData: StudentData // Access StudentData
    @State private var loginType: String = ""
    @State private var loginId: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

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
                TextField("Login ID", text: $loginId)
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

                Spacer()
            }
            .padding()
            .navigationTitle("Deep Presence")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .background(
                Group {
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
            )
        }
    }

    private func validateLogin() {
        if loginId.isEmpty || password.isEmpty {
            alertMessage = "Login ID and Password cannot be empty."
            showAlert = true
        } else if loginType.isEmpty {
            alertMessage = "Please select a login type."
            showAlert = true
        } else {
            // Simulate a successful login
            isLoggedIn = true
        }
    }
}
