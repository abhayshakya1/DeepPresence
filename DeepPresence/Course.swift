//
//  Course.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
import Foundation

struct Course: Identifiable, Codable {
    let id: UUID
    var name: String
    var code: String
}
