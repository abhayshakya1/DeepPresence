//
//  StudentLoader.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/12/25.
//
// StudentLoader.swift
import Foundation

func loadStudents() -> [Student] {
    guard let url = Bundle.main.url(forResource: "students", withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
        return []
    }

    let decoder = JSONDecoder()
    return (try? decoder.decode([Student].self, from: data)) ?? []
}
