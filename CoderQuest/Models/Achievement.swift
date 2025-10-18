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
    case streak50 = "streak_50"
    case perfectScore = "perfect_score"
    case speed50 = "speed_50"
    case speed100 = "speed_100"
    case speed250 = "speed_250"
    case speed500 = "speed_500"
    case allLanguages = "all_languages"
    case hardMode = "hard_mode"
    case master100 = "master_100"
    case master500 = "master_500"
    case master1000 = "master_1000"
    case master2500 = "master_2500"
    case master5000 = "master_5000"
    case nightOwl = "night_owl"
    case earlyBird = "early_bird"
    case weekendWarrior = "weekend_warrior"
    case marathonRunner = "marathon_runner"
    case centuryClub = "century_club"
    case perfectStreak = "perfect_streak"
    case speedDemon = "speed_demon"
    case dedicated = "dedicated"
    case veteran = "veteran"
    case legend = "legend"
}

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requiredCount: Int
    var currentCount: Int
    var isUnlocked: Bool
    var isClaimed: Bool
    let type: AchievementType
    let xpReward: Int
    let coinReward: Int
    
    var progress: Double {
        return min(Double(currentCount) / Double(requiredCount), 1.0)
    }
    
    // Custom coding keys for backward compatibility
    enum CodingKeys: String, CodingKey {
        case id, title, description, icon, requiredCount, currentCount
        case isUnlocked, isClaimed, type, xpReward, coinReward
    }
    
    // Custom decoder to handle missing isClaimed and coinReward fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        icon = try container.decode(String.self, forKey: .icon)
        requiredCount = try container.decode(Int.self, forKey: .requiredCount)
        currentCount = try container.decode(Int.self, forKey: .currentCount)
        isUnlocked = try container.decode(Bool.self, forKey: .isUnlocked)
        isClaimed = try container.decodeIfPresent(Bool.self, forKey: .isClaimed) ?? false
        type = try container.decode(AchievementType.self, forKey: .type)
        xpReward = try container.decode(Int.self, forKey: .xpReward)
        coinReward = try container.decodeIfPresent(Int.self, forKey: .coinReward) ?? 0
    }
    
    // Regular init for creating new achievements
    init(id: String, title: String, description: String, icon: String, 
         requiredCount: Int, currentCount: Int, isUnlocked: Bool, isClaimed: Bool,
         type: AchievementType, xpReward: Int, coinReward: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.requiredCount = requiredCount
        self.currentCount = currentCount
        self.isUnlocked = isUnlocked
        self.isClaimed = isClaimed
        self.type = type
        self.xpReward = xpReward
        self.coinReward = coinReward
    }
    
    static let allAchievements: [Achievement] = [
        // Beginner Achievements
        Achievement(id: "1", title: "First Victory", description: "Win your first quiz", icon: "star.fill", requiredCount: 1, currentCount: 0, isUnlocked: false, isClaimed: false, type: .firstWin, xpReward: 50, coinReward: 10),
        Achievement(id: "5", title: "Perfectionist", description: "Complete a quiz without mistakes", icon: "checkmark.seal.fill", requiredCount: 1, currentCount: 0, isUnlocked: false, isClaimed: false, type: .perfectScore, xpReward: 150, coinReward: 25),
        
        // Streak Achievements
        Achievement(id: "2", title: "Streak Master", description: "Get 5 correct answers in a row", icon: "flame.fill", requiredCount: 5, currentCount: 0, isUnlocked: false, isClaimed: false, type: .streak5, xpReward: 100, coinReward: 20),
        Achievement(id: "3", title: "Fire Storm", description: "Get 10 correct answers in a row", icon: "flame.circle.fill", requiredCount: 10, currentCount: 0, isUnlocked: false, isClaimed: false, type: .streak10, xpReward: 200, coinReward: 40),
        Achievement(id: "4", title: "Legendary Streak", description: "Get 20 correct answers in a row", icon: "sparkles", requiredCount: 20, currentCount: 0, isUnlocked: false, isClaimed: false, type: .streak20, xpReward: 500, coinReward: 100),
        Achievement(id: "16", title: "Unstoppable", description: "Get 50 correct answers in a row", icon: "flame.fill", requiredCount: 50, currentCount: 0, isUnlocked: false, isClaimed: false, type: .streak50, xpReward: 1500, coinReward: 300),
        
        // Speed/Question Achievements
        Achievement(id: "6", title: "Speed Demon", description: "Answer 50 questions correctly", icon: "bolt.fill", requiredCount: 50, currentCount: 0, isUnlocked: false, isClaimed: false, type: .speed50, xpReward: 200, coinReward: 30),
        Achievement(id: "7", title: "Lightning Fast", description: "Answer 100 questions correctly", icon: "bolt.circle.fill", requiredCount: 100, currentCount: 0, isUnlocked: false, isClaimed: false, type: .speed100, xpReward: 400, coinReward: 60),
        Achievement(id: "17", title: "Knowledge Seeker", description: "Answer 250 questions correctly", icon: "bolt.shield.fill", requiredCount: 250, currentCount: 0, isUnlocked: false, isClaimed: false, type: .speed250, xpReward: 800, coinReward: 150),
        Achievement(id: "18", title: "Master Mind", description: "Answer 500 questions correctly", icon: "brain.head.profile", requiredCount: 500, currentCount: 0, isUnlocked: false, isClaimed: false, type: .speed500, xpReward: 2000, coinReward: 400),
        
        // XP/Level Achievements
        Achievement(id: "10", title: "Centurion", description: "Reach 100 XP", icon: "100.circle.fill", requiredCount: 100, currentCount: 0, isUnlocked: false, isClaimed: false, type: .master100, xpReward: 100, coinReward: 25),
        Achievement(id: "11", title: "Grand Master", description: "Reach 500 XP", icon: "crown.fill", requiredCount: 500, currentCount: 0, isUnlocked: false, isClaimed: false, type: .master500, xpReward: 500, coinReward: 100),
        Achievement(id: "12", title: "Elite", description: "Reach 1000 XP", icon: "trophy.fill", requiredCount: 1000, currentCount: 0, isUnlocked: false, isClaimed: false, type: .master1000, xpReward: 1000, coinReward: 250),
        Achievement(id: "19", title: "Champion", description: "Reach 2500 XP", icon: "star.circle.fill", requiredCount: 2500, currentCount: 0, isUnlocked: false, isClaimed: false, type: .master2500, xpReward: 2000, coinReward: 500),
        Achievement(id: "20", title: "Legend", description: "Reach 5000 XP", icon: "crown.fill", requiredCount: 5000, currentCount: 0, isUnlocked: false, isClaimed: false, type: .master5000, xpReward: 5000, coinReward: 1000),
        
        // Language Achievement
        Achievement(id: "8", title: "Polyglot", description: "Try all programming languages", icon: "globe", requiredCount: 8, currentCount: 0, isUnlocked: false, isClaimed: false, type: .allLanguages, xpReward: 300, coinReward: 80),
        
        // Difficulty Achievement
        Achievement(id: "9", title: "Hard Mode Hero", description: "Complete 10 quizzes in hard mode", icon: "shield.fill", requiredCount: 10, currentCount: 0, isUnlocked: false, isClaimed: false, type: .hardMode, xpReward: 600, coinReward: 150),
        
        // Time-based Achievements
        Achievement(id: "13", title: "Night Owl", description: "Complete a quiz after midnight", icon: "moon.stars.fill", requiredCount: 1, currentCount: 0, isUnlocked: false, isClaimed: false, type: .nightOwl, xpReward: 75, coinReward: 15),
        Achievement(id: "14", title: "Early Bird", description: "Complete a quiz before 6 AM", icon: "sunrise.fill", requiredCount: 1, currentCount: 0, isUnlocked: false, isClaimed: false, type: .earlyBird, xpReward: 75, coinReward: 15),
        Achievement(id: "15", title: "Weekend Warrior", description: "Complete 5 quizzes on weekends", icon: "calendar.badge.clock", requiredCount: 5, currentCount: 0, isUnlocked: false, isClaimed: false, type: .weekendWarrior, xpReward: 150, coinReward: 40),
        
        // Games Played Achievements
        Achievement(id: "21", title: "Marathon Runner", description: "Play 25 total games", icon: "figure.run", requiredCount: 25, currentCount: 0, isUnlocked: false, isClaimed: false, type: .marathonRunner, xpReward: 300, coinReward: 75),
        Achievement(id: "22", title: "Century Club", description: "Play 100 total games", icon: "sportscourt.fill", requiredCount: 100, currentCount: 0, isUnlocked: false, isClaimed: false, type: .centuryClub, xpReward: 1000, coinReward: 250),
        
        // Special Achievements
        Achievement(id: "23", title: "Perfect Week", description: "Get 3 perfect scores in one session", icon: "rosette", requiredCount: 3, currentCount: 0, isUnlocked: false, isClaimed: false, type: .perfectStreak, xpReward: 500, coinReward: 120),
        Achievement(id: "24", title: "Speed Legend", description: "Answer 20 questions under 10 seconds each", icon: "timer", requiredCount: 20, currentCount: 0, isUnlocked: false, isClaimed: false, type: .speedDemon, xpReward: 400, coinReward: 100),
        Achievement(id: "25", title: "Dedicated Learner", description: "Play for 7 consecutive days", icon: "calendar.circle.fill", requiredCount: 7, currentCount: 0, isUnlocked: false, isClaimed: false, type: .dedicated, xpReward: 800, coinReward: 200),
        Achievement(id: "26", title: "Veteran", description: "Play for 30 consecutive days", icon: "medal.fill", requiredCount: 30, currentCount: 0, isUnlocked: false, isClaimed: false, type: .veteran, xpReward: 3000, coinReward: 750),
        Achievement(id: "27", title: "Coding Deity", description: "Reach level 50", icon: "star.leadinghalf.filled", requiredCount: 50, currentCount: 0, isUnlocked: false, isClaimed: false, type: .legend, xpReward: 10000, coinReward: 2500)
    ]
}

