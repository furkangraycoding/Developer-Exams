import Foundation

struct Flashcard: Identifiable, Codable, Hashable {
    let id = UUID()
    let question: String
    var choices: [String]
    let answer: String
    let point: Int
    
    mutating func shuffleChoices() {
        choices.shuffle()
    }
}
