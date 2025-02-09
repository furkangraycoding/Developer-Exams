//  ScoreManager.swift
//  FlashCard
//
//  Created by furkan gurcay on 16.11.2024.
//

import Foundation

class ScoreManager {
    static let shared = ScoreManager()
    
    // Menüye özgü skorları saklamak için anahtarları dinamik olarak oluşturacağız
    func getHighScoresKey(for menu: String) -> String {
        return "\(menu)_highScores"
    }
    
    // Yüksek skorları UserDefaults'tan yükler ve menu bazında filtreler
    func loadScores(for menu: String) -> [UserScore] {
        let highScoresKey = getHighScoresKey(for: menu)
        
        guard let data = UserDefaults.standard.data(forKey: highScoresKey),
              let allScores = try? JSONDecoder().decode([UserScore].self, from: data) else {
            return [] // Eğer skorlar yüklenemezse boş liste döner
        }
        
        return allScores
    }
    
    // Yüksek skorları UserDefaults'a kaydeder
    func saveScores(_ scores: [UserScore], for menu: String) {
        let highScoresKey = getHighScoresKey(for: menu)
        
        if let data = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(data, forKey: highScoresKey)
        }
    }
    
    // Yeni bir skoru ekleyip yüksek skorları günceller
    func addNewScore(_ score: UserScore) {
        var currentScores = loadScores(for: score.scoreMenu)
        currentScores.append(score)
        
        // Skorları azalan sırayla sıralıyoruz
        currentScores.sort { $0.score > $1.score }
        
        // Yalnızca en yüksek 3 skoru tutuyoruz
        if currentScores.count > 3 {
            currentScores = Array(currentScores.prefix(3))
        }
        
        // Skorları menüye göre kaydediyoruz
        saveScores(currentScores, for: score.scoreMenu)
    }
}
