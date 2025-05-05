//
//  Attendence.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import Foundation

// Attendance Model for Analytics
struct Attendance: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
