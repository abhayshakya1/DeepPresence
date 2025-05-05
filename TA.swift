//
//  TA.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/13/25.
//
import Foundation

struct TA: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let email: String
    let password: String
    var hasAccess: Bool 
}
