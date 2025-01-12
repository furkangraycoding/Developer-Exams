//
//  ScoreManager.swift
//  FlashCard
//
//  Created by furkan gurcay on 16.11.2024.
//

import Foundation

class ScoreManager {
    static let shared = ScoreManager()
    
    private let highScoresKey = "highScores"
    
    // Yüksek skorları UserDefaults'tan yükler
    func loadScores() -> [UserScore] {
        guard let data = UserDefaults.standard.data(forKey: highScoresKey),
              let scores = try? JSONDecoder().decode([UserScore].self, from: data) else {
            return [] // Eğer skorlar yüklenemezse boş liste döner
        }
        return scores
    }
    
    // Yüksek skorları UserDefaults'a kaydeder
    func saveScores(_ scores: [UserScore]) {
        if let data = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(data, forKey: highScoresKey)
        }
    }
    
    // Yeni bir skoru ekleyip yüksek skorları günceller
    func addNewScore(_ score: UserScore) {
        var currentScores = loadScores()
        currentScores.append(score)
        
        // Skorları azalan sırayla sıralıyoruz
        currentScores.sort { $0.score > $1.score }
        
        // Yalnızca en yüksek 3 skoru tutuyoruz
        if currentScores.count > 3 {
            currentScores = Array(currentScores.prefix(3))
        }
        
        saveScores(currentScores)
    }
}
