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
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
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
                        
                        Text("Statistics")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    // Level and XP Card
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.yellow)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Level \(progressManager.statistics.level)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("\(progressManager.statistics.totalXP) XP")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                        }
                        
                        // XP Progress Bar
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Next Level")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text("\(Int(progressManager.statistics.levelProgress * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 10)
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * progressManager.statistics.levelProgress, height: 10)
                                        .animation(.spring(), value: progressManager.statistics.levelProgress)
                                }
                            }
                            .frame(height: 10)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .shadow(color: .purple.opacity(0.3), radius: 10)
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
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .shadow(color: color.opacity(0.3), radius: 5)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(stat.language)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(stat.totalPoints) pts")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text(String(format: "%.1f%%", stat.accuracy))
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Questions")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(stat.totalQuestions)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("High Score")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(stat.highestScore)")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
        .padding(.horizontal)
    }
}
