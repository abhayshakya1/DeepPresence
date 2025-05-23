//
//  DeepPresenceApp.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/11/25.
//
import SwiftUI

@main
struct DeepPresenceApp: App {
    @StateObject private var studentData = StudentData()

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(studentData) // Provide StudentData
        }
    }
}
