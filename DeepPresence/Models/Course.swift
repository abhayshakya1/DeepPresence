//
//  Course.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import Foundation

struct Course: Identifiable, Codable {
    var id = UUID() // Make it mutable for decoding
    let courseName: String
    let courseId: String
    let semester: String
    let instructorEmail: String
    let instructorName: String
    let students: [Student]
    let enrolledStudentsCount: Int

    // Custom CodingKeys to exclude `id` from encoding/decoding
    enum CodingKeys: String, CodingKey {
        case courseName, courseId, semester, instructorEmail, instructorName, students, enrolledStudentsCount
    }
}
