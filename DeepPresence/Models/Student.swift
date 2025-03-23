//
//  Student.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import Foundation

struct Student: Identifiable, Codable, Hashable {
    var id = UUID() // Make it mutable for decoding
    let name: String
    let rollNo: String
    let email: String
    let password: String
    let course: String
    let instructor: String
    var isPresent: Bool = false // Add this property

    // Custom CodingKeys to exclude `id` from encoding/decoding
    enum CodingKeys: String, CodingKey {
        case name, rollNo, email, password, course, instructor, isPresent
    }

    // Custom initializer for Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        rollNo = try container.decode(String.self, forKey: .rollNo)
        email = try container.decode(String.self, forKey: .email)
        password = try container.decode(String.self, forKey: .password)
        course = try container.decode(String.self, forKey: .course)
        instructor = try container.decode(String.self, forKey: .instructor)
        isPresent = try container.decode(Bool.self, forKey: .isPresent)
    }

    // Custom initializer for manual creation
    init(id: UUID = UUID(), name: String, rollNo: String, email: String, password: String, course: String, instructor: String, isPresent: Bool = false) {
        self.id = id
        self.name = name
        self.rollNo = rollNo
        self.email = email
        self.password = password
        self.course = course
        self.instructor = instructor
        self.isPresent = isPresent
    }
}
