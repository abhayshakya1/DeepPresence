//
//  Student.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import Foundation

struct Student: Identifiable, Codable {
    let id: UUID
    let name: String
    let rollNo: String
    let email: String
    let course: String
    let instructor: String
}
