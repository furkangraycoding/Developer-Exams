//
//  Achievement.swift
//  CoderQuest
//
//  Enhanced Achievement System
//

import Foundation
import SwiftUI

enum AchievementType: String, Codable {
    case firstWin = "first_win"
    case streak5 = "streak_5"
    case streak10 = "streak_10"
    case streak20 = "streak_20"
    case perfectScore = "perfect_score"
    case speed50 = "speed_50"
    case speed100 = "speed_100"
    case allLanguages = "all_languages"
    case hardMode = "hard_mode"
    case master100 = "master_100"
    case master500 = "master_500"
    case master1000 = "master_1000"
    case nightOwl = "night_owl"
    case earlyBird = "early_bird"
    case weekendWarrior = "weekend_warrior"
}

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requiredCount: Int
    var currentCount: Int
    var isUnlocked: Bool
    let type: AchievementType
    let xpReward: Int
    
    var progress: Double {
        return min(Double(currentCount) / Double(requiredCount), 1.0)
    }
    
    static let allAchievements: [Achievement] = [
        Achievement(id: "1", title: "First Victory", description: "Win your first quiz", icon: "star.fill", requiredCount: 1, currentCount: 0, isUnlocked: false, type: .firstWin, xpReward: 50),
        Achievement(id: "2", title: "Streak Master", description: "Get 5 correct answers in a row", icon: "flame.fill", requiredCount: 5, currentCount: 0, isUnlocked: false, type: .streak5, xpReward: 100),
        Achievement(id: "3", title: "Fire Storm", description: "Get 10 correct answers in a row", icon: "flame.circle.fill", requiredCount: 10, currentCount: 0, isUnlocked: false, type: .streak10, xpReward: 200),
        Achievement(id: "4", title: "Legendary Streak", description: "Get 20 correct answers in a row", icon: "sparkles", requiredCount: 20, currentCount: 0, isUnlocked: false, type: .streak20, xpReward: 500),
        Achievement(id: "5", title: "Perfectionist", description: "Complete a quiz without mistakes", icon: "checkmark.seal.fill", requiredCount: 1, currentCount: 0, isUnlocked: false, type: .perfectScore, xpReward: 150),
        Achievement(id: "6", title: "Speed Demon", description: "Answer 50 questions correctly", icon: "bolt.fill", requiredCount: 50, currentCount: 0, isUnlocked: false, type: .speed50, xpReward: 200),
        Achievement(id: "7", title: "Lightning Fast", description: "Answer 100 questions correctly", icon: "bolt.circle.fill", requiredCount: 100, currentCount: 0, isUnlocked: false, type: .speed100, xpReward: 400),
        Achievement(id: "8", title: "Polyglot", description: "Try all programming languages", icon: "globe", requiredCount: 8, currentCount: 0, isUnlocked: false, type: .allLanguages, xpReward: 300),
        Achievement(id: "9", title: "Hard Mode Hero", description: "Complete 10 quizzes in hard mode", icon: "shield.fill", requiredCount: 10, currentCount: 0, isUnlocked: false, type: .hardMode, xpReward: 600),
        Achievement(id: "10", title: "Centurion", description: "Reach 100 total points", icon: "100.circle.fill", requiredCount: 100, currentCount: 0, isUnlocked: false, type: .master100, xpReward: 100),
        Achievement(id: "11", title: "Grand Master", description: "Reach 500 total points", icon: "crown.fill", requiredCount: 500, currentCount: 0, isUnlocked: false, type: .master500, xpReward: 500),
        Achievement(id: "12", title: "Legend", description: "Reach 1000 total points", icon: "trophy.fill", requiredCount: 1000, currentCount: 0, isUnlocked: false, type: .master1000, xpReward: 1000),
        Achievement(id: "13", title: "Night Owl", description: "Complete a quiz after midnight", icon: "moon.stars.fill", requiredCount: 1, currentCount: 0, isUnlocked: false, type: .nightOwl, xpReward: 75),
        Achievement(id: "14", title: "Early Bird", description: "Complete a quiz before 6 AM", icon: "sunrise.fill", requiredCount: 1, currentCount: 0, isUnlocked: false, type: .earlyBird, xpReward: 75),
        Achievement(id: "15", title: "Weekend Warrior", description: "Complete 5 quizzes on weekends", icon: "calendar.badge.clock", requiredCount: 5, currentCount: 0, isUnlocked: false, type: .weekendWarrior, xpReward: 150)
    ]
}

