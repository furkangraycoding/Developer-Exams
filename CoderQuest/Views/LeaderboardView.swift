import SwiftUI

struct LeaderboardView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedLanguage = "Swift"
    @State private var scores: [UserScore] = []
    
    let languages = ["Swift", "Python", "JavaScript", "Java", "Ruby", "C#", "Go", "Solidity"]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.1, blue: 0.25)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Language selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(languages, id: \.self) { language in
                                LanguageFilterButton(
                                    language: language,
                                    isSelected: selectedLanguage == language
                                ) {
                                    selectedLanguage = language
                                    loadScores()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Leaderboard
                    if scores.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "trophy")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("No scores yet")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("Be the first to play!")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(Array(scores.enumerated()), id: \.element.id) { index, score in
                                    LeaderboardRow(
                                        rank: index + 1,
                                        score: score
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .onAppear {
                loadScores()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func loadScores() {
        scores = ScoreManager.shared.loadScores(for: selectedLanguage)
            .sorted { $0.score > $1.score }
            .prefix(10)
            .map { $0 }
    }
}

struct LanguageFilterButton: View {
    let language: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(language)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.cyan.opacity(0.3) : Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.cyan : Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let score: UserScore
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                if rank <= 3 {
                    Image(systemName: rankIcon)
                        .font(.system(size: 24))
                        .foregroundColor(rankColor)
                } else {
                    Text("\(rank)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Username
            VStack(alignment: .leading, spacing: 4) {
                Text(score.username)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(score.scoreMenu)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Score
            HStack(spacing: 5) {
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
                
                Text("\(score.score)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(rank <= 3 ? rankColor.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(rank <= 3 ? rankColor.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75) // Silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
        default: return .gray
        }
    }
    
    private var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return ""
        }
    }
}
