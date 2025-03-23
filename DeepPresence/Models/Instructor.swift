//
//  Instructor.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/20/25.
//
import Foundation

struct Instructor: Identifiable, Codable {
    let id: UUID
    let name: String
    let email: String
    let password: String
    let courses: [Course]
}
