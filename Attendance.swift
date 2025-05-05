import Foundation

struct Attendance: Identifiable, Codable {
    let id = UUID()  // Ensures each attendance record has a unique identifier
    var date: String
    var status: String

    enum CodingKeys: String, CodingKey {
        case date = "date"
        case status = "attendance"
    }
}
