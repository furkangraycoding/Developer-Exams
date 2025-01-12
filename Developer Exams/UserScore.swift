import Foundation

struct UserScore: Identifiable, Codable {
    var id = UUID()
    var username: String
    var score: Int
}
