//
//  Statistics.swift
//  CoderQuest
//
//  Enhanced Statistics Tracking
//

import Foundation

enum DifficultyLevel: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var heartCount: Int {
        switch self {
        case .easy: return 5
        case .medium: return 3
        case .hard: return 1
        }
    }
    
    var timeLimit: Int? {
        switch self {
        case .easy: return nil
        case .medium: return 30
        case .hard: return 15
        }
    }
    
    var pointMultiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        }
    }
}

struct LanguageStatistics: Codable {
    var language: String
    var totalQuestions: Int
    var correctAnswers: Int
    var wrongAnswers: Int
    var totalPoints: Int
    var highestScore: Int
    var averageScore: Double
    var totalTimePlayed: TimeInterval
    var lastPlayedDate: Date?
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    init(language: String) {
        self.language = language
        self.totalQuestions = 0
        self.correctAnswers = 0
        self.wrongAnswers = 0
        self.totalPoints = 0
        self.highestScore = 0
        self.averageScore = 0
        self.totalTimePlayed = 0
        self.lastPlayedDate = nil
    }
}

struct UserStatistics: Codable {
    var totalXP: Int
    var level: Int
    var currentStreak: Int
    var longestStreak: Int
    var totalGamesPlayed: Int
    var totalQuestionsAnswered: Int
    var totalCorrectAnswers: Int
    var totalWrongAnswers: Int
    var perfectGames: Int
    var languageStats: [String: LanguageStatistics]
    var dailyGoalStreak: Int
    var lastPlayedDate: Date?
    
    var overallAccuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered) * 100
    }
    
    // Exponential leveling - much harder to level up
    var xpForNextLevel: Int {
        // Formula: base * (1.5 ^ (level - 1))
        let base = 100
        let exponent = pow(1.5, Double(level - 1))
        return Int(Double(base) * exponent)
    }
    
    var currentLevelXP: Int {
        var xpCounted = 0
        for lvl in 1..<level {
            let base = 100
            let exponent = pow(1.5, Double(lvl - 1))
            xpCounted += Int(Double(base) * exponent)
        }
        return totalXP - xpCounted
    }
    
    var levelProgress: Double {
        let xpNeeded = xpForNextLevel
        let currentXP = currentLevelXP
        guard xpNeeded > 0 else { return 0 }
        return Double(currentXP) / Double(xpNeeded)
    }
    
    init() {
        self.totalXP = 0
        self.level = 1
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalGamesPlayed = 0
        self.totalQuestionsAnswered = 0
        self.totalCorrectAnswers = 0
        self.totalWrongAnswers = 0
        self.perfectGames = 0
        self.languageStats = [:]
        self.dailyGoalStreak = 0
        self.lastPlayedDate = nil
    }
    
    mutating func addXP(_ amount: Int) {
        totalXP += amount
        // Calculate new level based on exponential formula
        var calculatedLevel = 1
        var xpThreshold = 0
        
        while true {
            let base = 100
            let exponent = pow(1.5, Double(calculatedLevel - 1))
            let xpNeeded = Int(Double(base) * exponent)
            xpThreshold += xpNeeded
            
            if totalXP < xpThreshold {
                break
            }
            calculatedLevel += 1
        }
        
        if calculatedLevel > level {
            level = calculatedLevel
        }
    }
}

