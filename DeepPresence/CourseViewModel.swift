//
//  CourseViewModel.swift
//  DeepPresence
//
//  Created by Abhay Shakya on 3/15/25.
//
import Foundation
import Alamofire
import Combine

class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchCourses() {   
        let url = "http://127.0.0.1:5000/courses" 

        isLoading = true
        AF.request(url).responseDecodable(of: [Course].self) { response in
            self.isLoading = false
            switch response.result {
            case .success(let courses):
                self.courses = courses
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                print("Error fetching courses: \(error.localizedDescription)")
            }
        }
    }
}
