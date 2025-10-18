import Foundation

enum DifficultyLevel: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    
    var pointMultiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        case .expert: return 3.0
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "yellow"
        case .hard: return "orange"
        case .expert: return "red"
        }
    }
}

struct QuizQuestion: Identifiable, Codable, Hashable {
    let id = UUID()
    let question: String
    var choices: [String]
    let answer: String
    let point: Int
    var hint: String?
    var explanation: String?
    var difficulty: DifficultyLevel
    var category: String
    
    private enum CodingKeys: String, CodingKey {
        case question, choices, answer, point, hint, explanation, difficulty, category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = try container.decode(String.self, forKey: .question)
        choices = try container.decode([String].self, forKey: .choices)
        answer = try container.decode(String.self, forKey: .answer)
        point = try container.decode(Int.self, forKey: .point)
        hint = try container.decodeIfPresent(String.self, forKey: .hint)
        explanation = try container.decodeIfPresent(String.self, forKey: .explanation)
        
        // Auto-determine difficulty based on points if not provided
        if let difficultyString = try? container.decode(String.self, forKey: .difficulty),
           let decodedDifficulty = DifficultyLevel(rawValue: difficultyString) {
            difficulty = decodedDifficulty
        } else {
            // Auto-assign difficulty based on points
            switch point {
            case 1...3: difficulty = .easy
            case 4...6: difficulty = .medium
            case 7...9: difficulty = .hard
            default: difficulty = .expert
            }
        }
        
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "General"
    }
    
    init(question: String, choices: [String], answer: String, point: Int, hint: String? = nil, explanation: String? = nil, difficulty: DifficultyLevel = .medium, category: String = "General") {
        self.question = question
        self.choices = choices
        self.answer = answer
        self.point = point
        self.hint = hint
        self.explanation = explanation
        self.difficulty = difficulty
        self.category = category
    }
    
    mutating func shuffleChoices() {
        choices.shuffle()
    }
    
    func finalPoints(withDifficulty useDifficultyMultiplier: Bool = true) -> Int {
        guard useDifficultyMultiplier else { return point }
        return Int(Double(point) * difficulty.pointMultiplier)
    }
}
