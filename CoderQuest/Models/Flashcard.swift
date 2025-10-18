import Foundation

struct Flashcard: Identifiable, Codable, Hashable {
    var id = UUID()
    let question: String
    var choices: [String]
    let answer: String
    let point: Int
    
    enum CodingKeys: String, CodingKey {
        case question, choices, answer, point
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.question = try container.decode(String.self, forKey: .question)
        self.choices = try container.decode([String].self, forKey: .choices)
        self.answer = try container.decode(String.self, forKey: .answer)
        self.point = try container.decode(Int.self, forKey: .point)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(question, forKey: .question)
        try container.encode(choices, forKey: .choices)
        try container.encode(answer, forKey: .answer)
        try container.encode(point, forKey: .point)
    }
    
    mutating func shuffleChoices() {
        choices.shuffle()
    }
}
