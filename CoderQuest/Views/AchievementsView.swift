//
//  AchievementsView.swift
//  CoderQuest
//
//  Achievement Badge System
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject var progressManager = ProgressManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedAchievement: Achievement?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.indigo.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Achievements")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(unlockedCount)/\(progressManager.achievements.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                .padding()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(progressManager.achievements) { achievement in
                            AchievementCard(achievement: achievement)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedAchievement = achievement
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
            
            // Achievement Detail Overlay
            if let achievement = selectedAchievement {
                ZStack {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedAchievement = nil
                            }
                        }
                    
                    AchievementDetailView(achievement: achievement)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    var unlockedCount: Int {
        progressManager.achievements.filter { $0.isUnlocked }.count
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [.gray.opacity(0.3), .gray.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: achievement.isUnlocked ? .yellow.opacity(0.5) : .clear, radius: 10)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 35))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            Text(achievement.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(achievement.isUnlocked ? .white : .gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 35)
            
            if !achievement.isUnlocked {
                ProgressView(value: achievement.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 4)
                
                Text("\(achievement.currentCount)/\(achievement.requiredCount)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .shadow(color: achievement.isUnlocked ? .yellow.opacity(0.2) : .clear, radius: 5)
        )
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: achievement.isUnlocked ? [.yellow, .orange] : [.gray.opacity(0.3), .gray.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: achievement.isUnlocked ? .yellow.opacity(0.5) : .clear, radius: 20)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 60))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            // Title
            Text(achievement.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Description
            Text(achievement.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            // Progress or Status
            if achievement.isUnlocked {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Unlocked!")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.2))
                )
            } else {
                VStack(spacing: 10) {
                    HStack {
                        Text("Progress")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text("\(Int(achievement.progress * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * achievement.progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(achievement.currentCount) / \(achievement.requiredCount)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                )
            }
            
            // XP Reward
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("+\(achievement.xpReward) XP Reward")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.2))
            )
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.black.opacity(0.95))
                .shadow(radius: 20)
        )
        .padding(40)
    }
}
