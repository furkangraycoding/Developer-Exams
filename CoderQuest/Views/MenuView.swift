import SwiftUI

struct MenuView: View {
    @Binding var isMenuVisible: Bool
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @ObservedObject var progressManager = ProgressManager.shared
    @State private var showStatistics = false
    @State private var showAchievements = false
    @State private var selectedDifficulty: DifficultyLevel = .easy
    
    // Enhanced color palette
    let menuItems = [
        ("Swift", Color.red, "swift"),
        ("Java", Color.orange, "cup.and.saucer.fill"),
        ("Javascript", Color.yellow, "{}"),
        ("Ruby", Color.purple, "diamond.fill"),
        ("Python", Color.blue, "🐍"),
        ("C#", Color.green, "number"),
        ("Go", Color.cyan, "figure.run"),
        ("Solidity", Color.pink, "cube.fill")
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.cyan.opacity(0.4), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background particles
            RandomShapesView(shapesWithPositions: $globalViewModel.shapesWithPositions)
                .environmentObject(globalViewModel)
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header with Stats
                VStack(spacing: 15) {
                    HStack {
                        // Profile Section
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Welcome back,")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            Text(globalViewModel.username)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Level Badge
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Level")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(progressManager.statistics.level)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                                .shadow(color: .yellow.opacity(0.3), radius: 5)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Quick Actions
                    HStack(spacing: 12) {
                        QuickActionButton(
                            icon: "chart.bar.fill",
                            title: "Stats",
                            color: .blue
                        ) {
                            showStatistics = true
                        }
                        
                        QuickActionButton(
                            icon: "trophy.fill",
                            title: "Achievements",
                            color: .yellow,
                            badge: progressManager.achievements.filter { $0.isUnlocked }.count
                        ) {
                            showAchievements = true
                        }
                        
                        QuickActionButton(
                            icon: "flame.fill",
                            title: "Streak \(progressManager.statistics.currentStreak)",
                            color: .orange
                        ) {}
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
                
                // Difficulty Selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select Difficulty")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                            DifficultyButton(
                                difficulty: difficulty,
                                isSelected: selectedDifficulty == difficulty
                            ) {
                                withAnimation(.spring()) {
                                    selectedDifficulty = difficulty
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
                
                // Language Selection Title
                Text("Choose Your Language")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Language Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(0..<menuItems.count, id: \.self) { index in
                            LanguageCard(
                                language: menuItems[index].0,
                                color: menuItems[index].1,
                                icon: menuItems[index].2,
                                stats: progressManager.statistics.languageStats[menuItems[index].0]
                            ) {
                                withAnimation(.spring()) {
                                    GlobalViewModel.shared.chosenMenu = menuItems[index].0
                                    GlobalViewModel.shared.chosenMenuColor = menuItems[index].1
                                    GlobalViewModel.shared.selectedDifficulty = selectedDifficulty
                                    isMenuVisible = false
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showStatistics) {
            StatisticsView()
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    var badge: Int? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    if let badge = badge, badge > 0 {
                        Text("\(badge)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Circle().fill(Color.red))
                            .offset(x: 8, y: -8)
                    }
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.15))
                    .shadow(color: color.opacity(0.3), radius: 5)
            )
        }
    }
}

struct DifficultyButton: View {
    let difficulty: DifficultyLevel
    let isSelected: Bool
    let action: () -> Void
    
    var color: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: difficulty == .easy ? "🟢" : difficulty == .medium ? "🟡" : "🔴")
                    .font(.title3)
                
                Text(difficulty.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .regular)
                
                Text("\(difficulty.heartCount) ❤️")
                    .font(.caption2)
                    .opacity(0.8)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.4) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

struct LanguageCard: View {
    let language: String
    let color: Color
    let icon: String
    let stats: LanguageStatistics?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.6), color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: color.opacity(0.4), radius: 10)
                    
                    if icon.count == 1 {
                        Text(icon)
                            .font(.system(size: 35))
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                }
                
                // Language Name
                Text(language)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Stats or Play indicator
                if let stats = stats {
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text("\(stats.totalPoints)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text(String(format: "%.0f%% Accuracy", stats.accuracy))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.caption2)
                            .foregroundColor(color)
                        Text("Start")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [color.opacity(0.6), color.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: color.opacity(0.2), radius: 8)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

