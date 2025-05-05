//
//  Course.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import Foundation

struct Course: Identifiable, Codable {
    var id = UUID() // Automatically generated UUID
    let courseName: String
    let courseId: String
    let semester: String

    // Custom CodingKeys to exclude `id` from encoding/decoding
    enum CodingKeys: String, CodingKey {
        case courseName = "course_name"
        case courseId = "course_id"
        case semester = "semester"
    }
}
