import Foundation

enum AchievementType: String, Codable {
    case firstWin = "First Victory"
    case streak5 = "5 Day Streak"
    case streak10 = "10 Day Streak"
    case perfectRound = "Perfect Round"
    case speedDemon = "Speed Demon"
    case centurion = "Centurion"
    case scholar = "Scholar"
    case polyglot = "Polyglot"
    case master = "Master"
    case legend = "Legend"
}

struct Achievement: Identifiable, Codable {
    let id: String
    let type: AchievementType
    let title: String
    let description: String
    let iconName: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    let requiredValue: Int
    var currentProgress: Int
    
    init(type: AchievementType, title: String, description: String, iconName: String, requiredValue: Int = 1) {
        self.id = type.rawValue
        self.type = type
        self.title = title
        self.description = description
        self.iconName = iconName
        self.isUnlocked = false
        self.unlockedDate = nil
        self.requiredValue = requiredValue
        self.currentProgress = 0
    }
    
    var progressPercentage: Double {
        return Double(currentProgress) / Double(requiredValue)
    }
    
    static let allAchievements: [Achievement] = [
        Achievement(type: .firstWin, title: "First Victory", description: "Complete your first quiz", iconName: "star.fill", requiredValue: 1),
        Achievement(type: .streak5, title: "Consistent Learner", description: "Play for 5 days in a row", iconName: "flame.fill", requiredValue: 5),
        Achievement(type: .streak10, title: "Dedicated Student", description: "Play for 10 days in a row", iconName: "bolt.fill", requiredValue: 10),
        Achievement(type: .perfectRound, title: "Perfect Round", description: "Answer 10 questions correctly in a row", iconName: "checkmark.seal.fill", requiredValue: 10),
        Achievement(type: .speedDemon, title: "Speed Demon", description: "Answer 20 questions in under 2 minutes", iconName: "hare.fill", requiredValue: 20),
        Achievement(type: .centurion, title: "Centurion", description: "Score 100 points in a single game", iconName: "100.circle.fill", requiredValue: 100),
        Achievement(type: .scholar, title: "Scholar", description: "Answer 500 questions correctly", iconName: "graduationcap.fill", requiredValue: 500),
        Achievement(type: .polyglot, title: "Polyglot", description: "Play quizzes in all 8 languages", iconName: "globe", requiredValue: 8),
        Achievement(type: .master, title: "Master Coder", description: "Score 1000 total points", iconName: "crown.fill", requiredValue: 1000),
        Achievement(type: .legend, title: "Legend", description: "Reach level 50", iconName: "sparkles", requiredValue: 50)
    ]
}
