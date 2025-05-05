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
    @Published var instructors: [Instructor] = [] // Add this line
    @Published var tas: [TA] = [] // Add this line
    @Published var courses: [Course] = [] // Add this line

    init() {
        // Load students, instructors, TAs, and courses from JSON or other data source
        students = loadStudents()
        instructors = loadInstructors() // Add this line
        tas = loadTAs() // Add this line
        courses = loadCourses() // Add this line
    }

    // Load students from JSON
    private func loadStudents() -> [Student] {
        guard let url = Bundle.main.url(forResource: "students", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load students.json")
            return []
        }

        let decoder = JSONDecoder()
        return (try? decoder.decode([Student].self, from: data)) ?? []
    }

    // Load instructors from JSON
    private func loadInstructors() -> [Instructor] {
        guard let url = Bundle.main.url(forResource: "instructors", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load instructors.json")
            return []
        }

        let decoder = JSONDecoder()
        return (try? decoder.decode([Instructor].self, from: data)) ?? []
    }

    // Load TAs from JSON
    private func loadTAs() -> [TA] {
        guard let url = Bundle.main.url(forResource: "tas", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load tas.json")
            return []
        }

        let decoder = JSONDecoder()
        return (try? decoder.decode([TA].self, from: data)) ?? []
    }

    // Load courses from JSON
    private func loadCourses() -> [Course] {
        guard let url = Bundle.main.url(forResource: "courses", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load courses.json")
            return []
        }

        let decoder = JSONDecoder()
        return (try? decoder.decode([Course].self, from: data)) ?? []
    }
}
