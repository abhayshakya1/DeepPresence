//
//  ContentView.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/11/25.
//
import SwiftUI
import UIKit
import Alamofire

struct ContentView: View {
    @EnvironmentObject private var studentData: StudentData // Access StudentData from the environment
    @State private var selectedImage: UIImage? = nil
    @State private var attendanceResults: [String] = []
    @State private var isUploading = false
    @State private var isImagePickerPresented = false

    var body: some View {
        VStack {
            // Image Upload Section
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }

            Button("Select Image") {
                isImagePickerPresented.toggle()
            }
            .padding()

            Button("Upload & Process Attendance") {
                if let image = selectedImage {
                    uploadImage(image: image)
                }
            }
            .padding()
            .disabled(isUploading || selectedImage == nil)

            // Attendance Results
            if !attendanceResults.isEmpty {
                Text("Attendance Results")
                    .font(.headline)
                    .padding(.top)
                List(attendanceResults, id: \.self) { student in
                    Text(student)
                }
            }

            // Student Database Section
            Text("Enrolled Students")
                .font(.headline)
                .padding(.top)
            List(studentData.students) { student in
                VStack(alignment: .leading) {
                    Text(student.name)
                        .font(.headline)
                    Text("Roll No: \(student.rollNo)")
                        .font(.subheadline)
                    Text("Email: \(student.email)")
                        .font(.subheadline)
                    Text("Course: \(student.course)")
                        .font(.subheadline)
                    Text("Instructor: \(student.instructor)")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .navigationTitle("DeepPresence")
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }

    private func uploadImage(image: UIImage) {
        isUploading = true
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            isUploading = false
            return
        }

        AF.upload(multipartFormData: { formData in
            formData.append(imageData, withName: "file", fileName: "classroom.jpg", mimeType: "image/jpeg")
        }, to: "https://your-fastapi-backend.com/upload/")
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let imageUrl = json["image_url"] as? String {
                    processAttendance(imageUrl: imageUrl)
                } else {
                    isUploading = false
                }
            case .failure(let error):
                print("Upload failed: \(error.localizedDescription)")
                isUploading = false
            }
        }
    }

    private func processAttendance(imageUrl: String) {
        AF.request("https://your-fastapi-backend.com/process/", method: .post,
                   parameters: ["image_url": imageUrl], encoding: JSONEncoding.default)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let students = json["recognized_students"] as? [String] {
                    attendanceResults = students
                } else {
                    attendanceResults = ["No students recognized"]
                }
            case .failure(let error):
                print("Processing failed: \(error.localizedDescription)")
                attendanceResults = ["Error processing attendance"]
            }
            isUploading = false
        }
    }
}
