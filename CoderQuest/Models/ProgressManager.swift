import Foundation
import Combine

class ProgressManager: ObservableObject {
    static let shared = ProgressManager()
    
    @Published var userProgress: UserProgress
    
    private let progressKey = "userProgress"
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            self.userProgress = progress
        } else {
            self.userProgress = UserProgress()
        }
    }
    
    func saveProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }
    
    func recordAnswer(isCorrect: Bool, points: Int) {
        userProgress.recordAnswer(isCorrect: isCorrect, points: points)
        saveProgress()
    }
    
    func addLanguage(_ language: String) {
        userProgress.languagesPlayed.insert(language)
        saveProgress()
    }
    
    func incrementGamesPlayed() {
        userProgress.gamesPlayed += 1
        userProgress.updateStreak()
        saveProgress()
    }
    
    func recordPerfectRound() {
        userProgress.perfectRounds += 1
        saveProgress()
    }
    
    func useHint() {
        userProgress.hintsUsed += 1
        saveProgress()
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        return userProgress.achievements.filter { $0.isUnlocked }
    }
    
    func checkForNewAchievements() -> [Achievement] {
        let previousUnlocked = Set(userProgress.achievements.filter { $0.isUnlocked }.map { $0.id })
        userProgress.checkAchievements()
        let currentUnlocked = Set(userProgress.achievements.filter { $0.isUnlocked }.map { $0.id })
        
        let newlyUnlocked = currentUnlocked.subtracting(previousUnlocked)
        saveProgress()
        
        return userProgress.achievements.filter { newlyUnlocked.contains($0.id) }
    }
}
