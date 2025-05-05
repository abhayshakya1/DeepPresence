//
//  Student.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import Foundation

struct Student: Identifiable, Codable {
    var id = UUID()
    let name: String
    let rollNo: String
    let course: String
    let instructor: String
    var attendence: String

    // Custom CodingKeys to exclude `id` from encoding/decoding
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case rollNo = "rollNo"
        case course = "course"
        case instructor = "instructor"
        case attendence = "attendence"
    }

}
