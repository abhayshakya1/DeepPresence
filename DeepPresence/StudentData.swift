//
//  SttudentData.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import Foundation
import SwiftUI

class StudentData: ObservableObject {
    @Published var students: [Student] = []
    @Published var courses: [Course] = [] // Add this line

    init() {
        // Load students and courses from JSON or other data source
        students = loadStudents()
        courses = loadCourses() // Add this line
    }

    private func loadStudents() -> [Student] {
        guard let url = Bundle.main.url(forResource: "students", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }

        let decoder = JSONDecoder()
        return (try? decoder.decode([Student].self, from: data)) ?? []
    }

    private func loadCourses() -> [Course] {
        // Load courses from JSON or other data source
        return [] // Replace with actual loading logic
    }
}
