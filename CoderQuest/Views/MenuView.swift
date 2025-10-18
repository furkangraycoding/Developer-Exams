import SwiftUI

struct MenuView: View {
    @Binding var isMenuVisible: Bool
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @ObservedObject var progressManager = ProgressManager.shared
    @State private var showStatistics = false
    @State private var showAchievements = false
    
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
            // Enhanced gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color.cyan.opacity(0.3),
                    Color.purple.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header with Stats
                VStack(spacing: 15) {
                    HStack {
                        // Enhanced Profile Section
                        HStack(spacing: 12) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.cyan, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                
                                Text(String(globalViewModel.username.prefix(1)).uppercased())
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .shadow(color: .cyan.opacity(0.5), radius: 8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome back,")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text(globalViewModel.username)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        // Enhanced Level Badge
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [.yellow.opacity(0.4), .orange.opacity(0.2)],
                                            center: .center,
                                            startRadius: 10,
                                            endRadius: 25
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                    .blur(radius: 5)
                                
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 38, height: 38)
                                
                                Image(systemName: "star.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Level")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(progressManager.statistics.level)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                Capsule()
                                    .fill(Color.white.opacity(0.12))
                                
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.yellow.opacity(0.5), .orange.opacity(0.3)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                            .shadow(color: .yellow.opacity(0.3), radius: 8)
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
            VStack(spacing: 10) {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [color.opacity(0.3), .clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 50, height: 50)
                            .blur(radius: 5)
                        
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(color)
                    }
                    
                    if let badge = badge, badge > 0 {
                        Text("\(badge)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.red, .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .red.opacity(0.5), radius: 4)
                            )
                            .offset(x: 5, y: -5)
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
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.4), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: color.opacity(0.2), radius: 6)
            )
        }
        .buttonStyle(ScaleButtonStyle())
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
            VStack(spacing: 10) {
                // Enhanced Icon with glow (smaller)
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [color.opacity(0.4), .clear],
                                center: .center,
                                startRadius: 15,
                                endRadius: 40
                            )
                        )
                        .frame(width: 70, height: 70)
                        .blur(radius: 8)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.8), color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 55, height: 55)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: color.opacity(0.5), radius: 10)
                    
                    if icon.count == 1 {
                        Text(icon)
                            .font(.system(size: 28))
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                // Language Name
                Text(language)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Enhanced Stats (compact)
                if let stats = stats {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text("\(stats.totalPoints)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.2))
                    )
                } else {
                    Text("Start")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(color.opacity(0.2))
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white.opacity(0.08))
                    
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.6), color.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
                .shadow(color: color.opacity(0.3), radius: 10)
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

