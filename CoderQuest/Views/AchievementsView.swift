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
            // Enhanced background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color.indigo.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Enhanced Header
                VStack(spacing: 15) {
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                Text("Back")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                            )
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Achievements")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("\(unlockedCount) of \(progressManager.achievements.count) unlocked")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // Progress Circle
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: progressPercentage)
                                .stroke(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(), value: progressPercentage)
                            
                            Text("\(Int(progressPercentage * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.bottom, 10)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(progressManager.achievements) { achievement in
                            AchievementCard(achievement: achievement)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        selectedAchievement = achievement
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
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
    
    var progressPercentage: Double {
        guard progressManager.achievements.count > 0 else { return 0 }
        return Double(unlockedCount) / Double(progressManager.achievements.count)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var cardColor: (primary: Color, secondary: Color) {
        if achievement.isUnlocked {
            // Vibrant colors based on achievement type
            switch achievement.type {
            case .firstWin, .perfectScore:
                return (.green, .mint)
            case .streak5, .streak10, .streak20:
                return (.orange, .yellow)
            case .speed50, .speed100:
                return (.blue, .cyan)
            case .allLanguages:
                return (.purple, .pink)
            case .hardMode:
                return (.red, .orange)
            case .master100, .master500, .master1000:
                return (.yellow, .orange)
            case .nightOwl, .earlyBird, .weekendWarrior:
                return (.indigo, .purple)
            }
        } else {
            return (.gray.opacity(0.2), .gray.opacity(0.1))
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Outer glow for unlocked achievements
                if achievement.isUnlocked {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [cardColor.primary.opacity(0.4), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 100, height: 100)
                        .blur(radius: 10)
                }
                
                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [cardColor.primary, cardColor.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: achievement.isUnlocked ? cardColor.primary.opacity(0.6) : .clear,
                        radius: achievement.isUnlocked ? 15 : 0
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                achievement.isUnlocked ? 
                                    Color.white.opacity(0.3) : 
                                    Color.clear,
                                lineWidth: 2
                            )
                    )
                
                // Icon
                Image(systemName: achievement.icon)
                    .font(.system(size: 35, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray.opacity(0.4))
                
                // Locked overlay
                if !achievement.isUnlocked {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            
            Text(achievement.title)
                .font(.subheadline)
                .fontWeight(achievement.isUnlocked ? .bold : .regular)
                .foregroundColor(achievement.isUnlocked ? .white : .gray.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 35)
            
            // Status section with fixed height
            VStack(spacing: 4) {
                if !achievement.isUnlocked {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * achievement.progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    Text("\(achievement.currentCount)/\(achievement.requiredCount)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.gray.opacity(0.6))
                } else {
                    Spacer()
                        .frame(height: 6)
                    
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("Unlocked!")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.2))
                    )
                }
            }
            .frame(height: 34)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    achievement.isUnlocked ?
                        Color.white.opacity(0.12) :
                        Color.white.opacity(0.05)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            achievement.isUnlocked ?
                                LinearGradient(
                                    colors: [cardColor.primary.opacity(0.5), cardColor.secondary.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [.clear, .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: 1.5
                        )
                )
                .shadow(
                    color: achievement.isUnlocked ? cardColor.primary.opacity(0.3) : .clear,
                    radius: achievement.isUnlocked ? 10 : 0
                )
        )
        .scaleEffect(achievement.isUnlocked ? 1.0 : 0.95)
        .animation(.spring(response: 0.4), value: achievement.isUnlocked)
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    
    var detailColor: (primary: Color, secondary: Color) {
        if achievement.isUnlocked {
            switch achievement.type {
            case .firstWin, .perfectScore:
                return (.green, .mint)
            case .streak5, .streak10, .streak20:
                return (.orange, .yellow)
            case .speed50, .speed100:
                return (.blue, .cyan)
            case .allLanguages:
                return (.purple, .pink)
            case .hardMode:
                return (.red, .orange)
            case .master100, .master500, .master1000:
                return (.yellow, .orange)
            case .nightOwl, .earlyBird, .weekendWarrior:
                return (.indigo, .purple)
            }
        } else {
            return (.gray.opacity(0.3), .gray.opacity(0.5))
        }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // Icon with enhanced glow
            ZStack {
                if achievement.isUnlocked {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [detailColor.primary.opacity(0.6), .clear],
                                center: .center,
                                startRadius: 30,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                }
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [detailColor.primary, detailColor.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: achievement.isUnlocked ? detailColor.primary.opacity(0.7) : .clear, radius: 25)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(achievement.isUnlocked ? 0.4 : 0), lineWidth: 3)
                    )
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray.opacity(0.4))
                
                if !achievement.isUnlocked {
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.6))
                }
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
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title3)
                            .foregroundColor(detailColor.primary)
                        Text("Achievement Unlocked!")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [detailColor.primary.opacity(0.3), detailColor.secondary.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            colors: [detailColor.primary, detailColor.secondary],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    )
                    .shadow(color: detailColor.primary.opacity(0.4), radius: 10)
                    
                    Text(achievement.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
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
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
                Text("+\(achievement.xpReward) XP")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                    )
            )
            .shadow(color: .yellow.opacity(0.4), radius: 10)
        }
        .padding(35)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 35)
                    .fill(Color.black.opacity(0.95))
                
                RoundedRectangle(cornerRadius: 35)
                    .stroke(
                        achievement.isUnlocked ?
                            LinearGradient(
                                colors: [detailColor.primary.opacity(0.6), detailColor.secondary.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [.gray.opacity(0.3), .gray.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                        lineWidth: 2
                    )
            }
            .shadow(
                color: achievement.isUnlocked ? detailColor.primary.opacity(0.5) : .black.opacity(0.3),
                radius: 30
            )
        )
        .padding(40)
    }
}

