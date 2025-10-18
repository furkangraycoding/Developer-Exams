import SwiftUI

struct AchievementsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var progressManager = ProgressManager.shared
    
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header stats
                        HStack(spacing: 20) {
                            StatPill(
                                value: "\(progressManager.userProgress.unlockedAchievementsCount)",
                                label: "Unlocked",
                                color: .yellow
                            )
                            
                            StatPill(
                                value: "\(Achievement.allAchievements.count - progressManager.userProgress.unlockedAchievementsCount)",
                                label: "Locked",
                                color: .gray
                            )
                        }
                        .padding(.top, 20)
                        .padding(.horizontal)
                        
                        // Achievements list
                        LazyVStack(spacing: 15) {
                            ForEach(progressManager.userProgress.achievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationTitle("Achievements")
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
        }
        .preferredColorScheme(.dark)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(achievement.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
                
                Text(achievement.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                if !achievement.isUnlocked {
                    ProgressBar(
                        progress: achievement.progressPercentage,
                        color: .yellow
                    )
                    .frame(height: 6)
                    
                    Text("\(achievement.currentProgress) / \(achievement.requiredValue)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                } else if let date = achievement.unlockedDate {
                    Text("Unlocked \(formatDate(date))")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(achievement.isUnlocked ? 0.08 : 0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(achievement.isUnlocked ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct StatPill: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.1))
        )
    }
}

struct ProgressBar: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.1))
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: geometry.size.width * progress)
            }
        }
    }
}
