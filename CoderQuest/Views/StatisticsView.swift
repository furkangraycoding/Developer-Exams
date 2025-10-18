//
//  StatisticsView.swift
//  CoderQuest
//
//  Statistics Dashboard with Analytics
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var progressManager = ProgressManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Enhanced background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(red: 0.15, green: 0.05, blue: 0.25),
                    Color.purple.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Enhanced Header
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
                        
                        VStack(spacing: 2) {
                            Text("Statistics")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Your Progress")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                    .padding()
                    
                    // Enhanced Level and XP Card
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [.yellow.opacity(0.4), .orange.opacity(0.2)],
                                            center: .center,
                                            startRadius: 20,
                                            endRadius: 60
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                                    .blur(radius: 10)
                                
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    )
                                
                                Image(systemName: "star.fill")
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Level \(progressManager.statistics.level)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 5) {
                                    Text("\(progressManager.statistics.totalXP)")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.yellow)
                                    
                                    Text("XP")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Enhanced XP Progress Bar
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Progress to Level \(progressManager.statistics.level + 1)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                                Text("\(Int(progressManager.statistics.levelProgress * 100))%")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * progressManager.statistics.levelProgress, height: 12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                        .animation(.spring(response: 0.6), value: progressManager.statistics.levelProgress)
                                }
                            }
                            .frame(height: 12)
                            
                            Text("\(progressManager.statistics.xpForNextLevel - (progressManager.statistics.totalXP % progressManager.statistics.xpForNextLevel)) XP to next level")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(25)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.08))
                            
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    LinearGradient(
                                        colors: [.yellow.opacity(0.5), .orange.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                        .shadow(color: .yellow.opacity(0.3), radius: 15)
                    )
                    .padding(.horizontal)
                    
                    // Quick Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        StatCard(
                            icon: "gamecontroller.fill",
                            title: "Games Played",
                            value: "\(progressManager.statistics.totalGamesPlayed)",
                            color: .blue
                        )
                        
                        StatCard(
                            icon: "checkmark.circle.fill",
                            title: "Accuracy",
                            value: String(format: "%.1f%%", progressManager.statistics.overallAccuracy),
                            color: .green
                        )
                        
                        StatCard(
                            icon: "flame.fill",
                            title: "Current Streak",
                            value: "\(progressManager.statistics.currentStreak)",
                            color: .orange
                        )
                        
                        StatCard(
                            icon: "star.circle.fill",
                            title: "Perfect Games",
                            value: "\(progressManager.statistics.perfectGames)",
                            color: .yellow
                        )
                    }
                    .padding(.horizontal)
                    
                    // Detailed Stats
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Performance")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            StatRow(
                                label: "Total Questions",
                                value: "\(progressManager.statistics.totalQuestionsAnswered)"
                            )
                            
                            StatRow(
                                label: "Correct Answers",
                                value: "\(progressManager.statistics.totalCorrectAnswers)",
                                color: .green
                            )
                            
                            StatRow(
                                label: "Wrong Answers",
                                value: "\(progressManager.statistics.totalWrongAnswers)",
                                color: .red
                            )
                            
                            StatRow(
                                label: "Longest Streak",
                                value: "\(progressManager.statistics.longestStreak)",
                                color: .orange
                            )
                            
                            StatRow(
                                label: "Daily Goal Streak",
                                value: "\(progressManager.statistics.dailyGoalStreak) days",
                                color: .blue
                            )
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.horizontal)
                    }
                    
                    // Language Statistics
                    if !progressManager.statistics.languageStats.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Language Progress")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(Array(progressManager.statistics.languageStats.values.sorted(by: { $0.totalPoints > $1.totalPoints })), id: \.language) { langStat in
                                LanguageStatCard(stat: langStat)
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 40
                        )
                    )
                    .frame(width: 60, height: 60)
                    .blur(radius: 8)
                
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.08))
                
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.4), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: color.opacity(0.3), radius: 8)
        )
    }
}

struct StatRow: View {
    let label: String
    let value: String
    var color: Color = .white
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct LanguageStatCard: View {
    let stat: LanguageStatistics
    
    var languageColor: Color {
        switch stat.language {
        case "Swift": return .red
        case "Java": return .orange
        case "Javascript": return .yellow
        case "Ruby": return .purple
        case "Python": return .blue
        case "C#": return .green
        case "Go": return .cyan
        case "Solidity": return .pink
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                HStack(spacing: 10) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [languageColor, languageColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(stat.language.prefix(1)))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    Text(stat.language)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("\(stat.totalPoints)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                    Text("points")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack(spacing: 15) {
                StatMiniCard(
                    title: "Accuracy",
                    value: String(format: "%.1f%%", stat.accuracy),
                    color: .green
                )
                
                StatMiniCard(
                    title: "Questions",
                    value: "\(stat.totalQuestions)",
                    color: .blue
                )
                
                StatMiniCard(
                    title: "Best",
                    value: "\(stat.highestScore)",
                    color: .orange
                )
            }
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.08))
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [languageColor.opacity(0.5), languageColor.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            .shadow(color: languageColor.opacity(0.3), radius: 10)
        )
        .padding(.horizontal)
    }
}

struct StatMiniCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
        )
    }
}

