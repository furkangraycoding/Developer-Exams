//
//  ProgressManager.swift
//  CoderQuest
//
//  Manages user progress, statistics, and achievements
//

import Foundation
import Combine

class ProgressManager: ObservableObject {
    static let shared = ProgressManager()
    
    @Published var statistics: UserStatistics
    @Published var achievements: [Achievement]
    @Published var recentlyUnlockedAchievements: [Achievement] = []
    
    private let statisticsKey = "userStatistics"
    private let achievementsKey = "userAchievements"
    
    init() {
        // Load statistics
        if let data = UserDefaults.standard.data(forKey: statisticsKey),
           let stats = try? JSONDecoder().decode(UserStatistics.self, from: data) {
            self.statistics = stats
        } else {
            self.statistics = UserStatistics()
        }
        
        // Load achievements
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let savedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            self.achievements = savedAchievements
        } else {
            self.achievements = Achievement.allAchievements
        }
    }
    
    func saveStatistics() {
        if let data = try? JSONEncoder().encode(statistics) {
            UserDefaults.standard.set(data, forKey: statisticsKey)
        }
    }
    
    func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }
    
    func recordGameSession(language: String, score: Int, questionsAnswered: Int, correctAnswers: Int, difficulty: DifficultyLevel, timePlayed: TimeInterval, isPerfect: Bool) {
        // Update language stats
        var langStats = statistics.languageStats[language] ?? LanguageStatistics(language: language)
        langStats.totalQuestions += questionsAnswered
        langStats.correctAnswers += correctAnswers
        langStats.wrongAnswers += (questionsAnswered - correctAnswers)
        langStats.totalPoints += score
        langStats.highestScore = max(langStats.highestScore, score)
        
        let totalGames = statistics.totalGamesPlayed + 1
        let currentAverage = langStats.averageScore
        langStats.averageScore = (currentAverage * Double(totalGames - 1) + Double(score)) / Double(totalGames)
        langStats.totalTimePlayed += timePlayed
        langStats.lastPlayedDate = Date()
        
        statistics.languageStats[language] = langStats
        
        // Update overall stats
        statistics.totalGamesPlayed += 1
        statistics.totalQuestionsAnswered += questionsAnswered
        statistics.totalCorrectAnswers += correctAnswers
        statistics.totalWrongAnswers += (questionsAnswered - correctAnswers)
        
        if isPerfect {
            statistics.perfectGames += 1
        }
        
        // Award XP based on performance
        let baseXP = score
        let difficultyBonus = Int(Double(baseXP) * (difficulty.pointMultiplier - 1.0))
        let perfectBonus = isPerfect ? 50 : 0
        let totalXP = baseXP + difficultyBonus + perfectBonus
        
        statistics.addXP(totalXP)
        
        // Update daily streak
        updateDailyStreak()
        
        // Check achievements
        checkAchievements(language: language, score: score, difficulty: difficulty, isPerfect: isPerfect)
        
        saveStatistics()
    }
    
    func updateStreak(correct: Bool) {
        if correct {
            statistics.currentStreak += 1
            statistics.longestStreak = max(statistics.longestStreak, statistics.currentStreak)
            print("✅ Streak updated - Current: \(statistics.currentStreak), Longest: \(statistics.longestStreak)")
            
            // Check streak achievements immediately
            checkStreakAchievements()
        } else {
            statistics.currentStreak = 0
            print("❌ Streak reset to 0")
        }
        saveStatistics()
    }
    
    private func checkStreakAchievements() {
        for index in achievements.indices {
            var achievement = achievements[index]
            
            if achievement.isUnlocked {
                continue
            }
            
            switch achievement.type {
            case .streak5:
                achievement.currentCount = statistics.longestStreak
                if statistics.longestStreak >= 5 {
                    print("🎯 Unlocking Streak 5 achievement!")
                    unlockAchievement(at: index)
                }
            case .streak10:
                achievement.currentCount = statistics.longestStreak
                if statistics.longestStreak >= 10 {
                    print("🎯 Unlocking Streak 10 achievement!")
                    unlockAchievement(at: index)
                }
            case .streak20:
                achievement.currentCount = statistics.longestStreak
                if statistics.longestStreak >= 20 {
                    print("🎯 Unlocking Streak 20 achievement!")
                    unlockAchievement(at: index)
                }
            default:
                break
            }
            
            achievements[index] = achievement
        }
        
        saveAchievements()
    }
    
    private func updateDailyStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastPlayed = statistics.lastPlayedDate {
            let lastPlayedDay = calendar.startOfDay(for: lastPlayed)
            let daysDifference = calendar.dateComponents([.day], from: lastPlayedDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                statistics.dailyGoalStreak += 1
            } else if daysDifference > 1 {
                statistics.dailyGoalStreak = 1
            }
        } else {
            statistics.dailyGoalStreak = 1
        }
        
        statistics.lastPlayedDate = Date()
    }
    
    private func checkAchievements(language: String, score: Int, difficulty: DifficultyLevel, isPerfect: Bool) {
        print("🔍 Checking achievements - Stats: Games:\(statistics.totalGamesPlayed), Correct:\(statistics.totalCorrectAnswers), XP:\(statistics.totalXP), Perfect:\(isPerfect)")
        // Don't clear recent achievements here - they might have been unlocked during gameplay
        
        for index in achievements.indices {
            var achievement = achievements[index]
            
            if achievement.isUnlocked {
                continue
            }
            
            switch achievement.type {
            case .firstWin:
                achievement.currentCount = statistics.totalGamesPlayed
                if statistics.totalGamesPlayed >= 1 {
                    print("🎯 First game completed! Unlocking First Victory achievement")
                    unlockAchievement(at: index)
                }
                
            case .streak5:
                achievement.currentCount = statistics.longestStreak
                if statistics.longestStreak >= 5 {
                    unlockAchievement(at: index)
                }
                
            case .streak10:
                achievement.currentCount = statistics.longestStreak
                if statistics.longestStreak >= 10 {
                    unlockAchievement(at: index)
                }
                
            case .streak20:
                achievement.currentCount = statistics.longestStreak
                if statistics.longestStreak >= 20 {
                    unlockAchievement(at: index)
                }
                
            case .perfectScore:
                achievement.currentCount = statistics.perfectGames
                if isPerfect {
                    print("🎯 Perfect game! Unlocking Perfectionist achievement")
                    unlockAchievement(at: index)
                }
                
            case .speed50:
                achievement.currentCount = statistics.totalCorrectAnswers
                if statistics.totalCorrectAnswers >= 50 {
                    print("🎯 Reached 50 correct answers! Unlocking Speed Demon")
                    unlockAchievement(at: index)
                }
                
            case .speed100:
                achievement.currentCount = statistics.totalCorrectAnswers
                if statistics.totalCorrectAnswers >= 100 {
                    print("🎯 Reached 100 correct answers! Unlocking Lightning Fast")
                    unlockAchievement(at: index)
                }
                
            case .allLanguages:
                achievement.currentCount = statistics.languageStats.count
                if statistics.languageStats.count >= 8 {
                    print("🎯 Tried all \(statistics.languageStats.count) languages! Unlocking Polyglot")
                    unlockAchievement(at: index)
                }
                
            case .hardMode:
                if difficulty == .hard {
                    achievement.currentCount += 1
                    if achievement.currentCount >= 10 {
                        unlockAchievement(at: index)
                    }
                }
                
            case .master100:
                achievement.currentCount = statistics.totalXP
                if statistics.totalXP >= 100 {
                    print("🎯 Reached 100 XP! Unlocking Centurion")
                    unlockAchievement(at: index)
                }
                
            case .master500:
                achievement.currentCount = statistics.totalXP
                if statistics.totalXP >= 500 {
                    print("🎯 Reached 500 XP! Unlocking Grand Master")
                    unlockAchievement(at: index)
                }
                
            case .master1000:
                achievement.currentCount = statistics.totalXP
                if statistics.totalXP >= 1000 {
                    print("🎯 Reached 1000 XP! Unlocking Legend")
                    unlockAchievement(at: index)
                }
                
            case .nightOwl:
                let hour = Calendar.current.component(.hour, from: Date())
                if hour >= 0 && hour < 6 {
                    achievement.currentCount = 1
                    unlockAchievement(at: index)
                }
                
            case .earlyBird:
                let hour = Calendar.current.component(.hour, from: Date())
                if hour >= 4 && hour < 6 {
                    achievement.currentCount = 1
                    unlockAchievement(at: index)
                }
                
            case .weekendWarrior:
                let weekday = Calendar.current.component(.weekday, from: Date())
                if weekday == 1 || weekday == 7 {
                    achievement.currentCount += 1
                    if achievement.currentCount >= 5 {
                        unlockAchievement(at: index)
                    }
                }
            }
            
            achievements[index] = achievement
        }
        
        saveAchievements()
    }
    
    private func unlockAchievement(at index: Int) {
        // Only unlock if not already unlocked
        guard !achievements[index].isUnlocked else {
            print("⚠️ Achievement '\(achievements[index].title)' already unlocked, skipping")
            return
        }
        
        print("🎉 Unlocking achievement: \(achievements[index].title) (XP Reward: \(achievements[index].xpReward))")
        achievements[index].isUnlocked = true
        
        // Make sure we're not adding duplicates
        if !recentlyUnlockedAchievements.contains(where: { $0.id == achievements[index].id }) {
            recentlyUnlockedAchievements.append(achievements[index])
            print("✅ Achievement added to recent list, total recent: \(recentlyUnlockedAchievements.count)")
        }
        
        statistics.addXP(achievements[index].xpReward)
        saveStatistics()
        saveAchievements()
    }
    
    func clearRecentAchievements() {
        print("🗑️ Clearing \(recentlyUnlockedAchievements.count) recent achievements")
        recentlyUnlockedAchievements.removeAll()
        print("✅ Recent achievements cleared, count: \(recentlyUnlockedAchievements.count)")
    }
    
    func resetProgress() {
        statistics = UserStatistics()
        achievements = Achievement.allAchievements
        saveStatistics()
        saveAchievements()
    }
}

