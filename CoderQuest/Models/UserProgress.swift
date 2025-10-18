import Foundation

struct UserProgress: Codable {
    var totalScore: Int
    var totalQuestionsAnswered: Int
    var correctAnswers: Int
    var wrongAnswers: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastPlayedDate: Date?
    var level: Int
    var experiencePoints: Int
    var hintsUsed: Int
    var achievements: [Achievement]
    var languagesPlayed: [String] // Changed from Set to Array for Codable
    var gamesPlayed: Int
    var perfectRounds: Int
    var fastestTime: TimeInterval?
    
    init() {
        self.totalScore = 0
        self.totalQuestionsAnswered = 0
        self.correctAnswers = 0
        self.wrongAnswers = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastPlayedDate = nil
        self.level = 1
        self.experiencePoints = 0
        self.hintsUsed = 0
        self.achievements = Achievement.allAchievements
        self.languagesPlayed = []
        self.gamesPlayed = 0
        self.perfectRounds = 0
        self.fastestTime = nil
        print("✅ UserProgress initialized")
    }
    
    var accuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestionsAnswered) * 100
    }
    
    var experienceToNextLevel: Int {
        return level * 100
    }
    
    var experienceProgress: Double {
        return Double(experiencePoints) / Double(experienceToNextLevel)
    }
    
    mutating func addExperience(_ points: Int) {
        experiencePoints += points
        
        while experiencePoints >= experienceToNextLevel {
            experiencePoints -= experienceToNextLevel
            level += 1
            checkAchievements()
        }
    }
    
    mutating func recordAnswer(isCorrect: Bool, points: Int) {
        totalQuestionsAnswered += 1
        
        if isCorrect {
            correctAnswers += 1
            totalScore += points
            addExperience(points * 2)
        } else {
            wrongAnswers += 1
        }
        
        checkAchievements()
    }
    
    mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastPlayed = lastPlayedDate {
            let lastPlayedDay = calendar.startOfDay(for: lastPlayed)
            let daysDifference = calendar.dateComponents([.day], from: lastPlayedDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                currentStreak += 1
            } else if daysDifference > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        lastPlayedDate = Date()
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        checkAchievements()
    }
    
    mutating func checkAchievements() {
        for index in achievements.indices {
            guard !achievements[index].isUnlocked else { continue }
            
            switch achievements[index].type {
            case .firstWin:
                if gamesPlayed >= 1 {
                    unlockAchievement(at: index)
                }
            case .streak5:
                if currentStreak >= 5 {
                    unlockAchievement(at: index)
                }
            case .streak10:
                if currentStreak >= 10 {
                    unlockAchievement(at: index)
                }
            case .perfectRound:
                achievements[index].currentProgress = perfectRounds
                if perfectRounds >= achievements[index].requiredValue {
                    unlockAchievement(at: index)
                }
            case .speedDemon:
                // This is checked during game play
                break
            case .centurion:
                // This is checked during game play
                break
            case .scholar:
                achievements[index].currentProgress = correctAnswers
                if correctAnswers >= 500 {
                    unlockAchievement(at: index)
                }
            case .polyglot:
                achievements[index].currentProgress = languagesPlayed.count
                if languagesPlayed.count >= 8 {
                    unlockAchievement(at: index)
                }
            case .master:
                achievements[index].currentProgress = totalScore
                if totalScore >= 1000 {
                    unlockAchievement(at: index)
                }
            case .legend:
                achievements[index].currentProgress = level
                if level >= 50 {
                    unlockAchievement(at: index)
                }
            }
        }
    }
    
    private mutating func unlockAchievement(at index: Int) {
        achievements[index].isUnlocked = true
        achievements[index].unlockedDate = Date()
        addExperience(100) // Bonus XP for achievements
    }
    
    var unlockedAchievementsCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
}
