import SwiftUI

struct GameOverView: View {
    @ObservedObject var viewModel: QuizViewModel
    let onDismiss: () -> Void
    @State private var animateContent = false
    @StateObject private var progressManager = ProgressManager.shared
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent dismissing when tapping background
                }
            
            VStack(spacing: 25) {
                // Trophy animation
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.yellow.opacity(0.3), .orange.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateContent ? 1.0 : 0.5)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(animateContent ? 0 : -180))
                }
                
                Text("Game Over!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(animateContent ? 1 : 0)
                
                // Score card
                VStack(spacing: 20) {
                    ScoreRow(
                        icon: "star.fill",
                        label: "Final Score",
                        value: "\(viewModel.correctAnswersCount)",
                        color: .yellow
                    )
                    
                    ScoreRow(
                        icon: "checkmark.circle.fill",
                        label: "Questions Answered",
                        value: "\(viewModel.totalQuestions)",
                        color: .green
                    )
                    
                    ScoreRow(
                        icon: "flame.fill",
                        label: "Best Streak",
                        value: "\(viewModel.correctStreak)",
                        color: .orange
                    )
                    
                    if viewModel.comboMultiplier > 1 {
                        ScoreRow(
                            icon: "bolt.fill",
                            label: "Max Combo",
                            value: "x\(viewModel.comboMultiplier)",
                            color: .cyan
                        )
                    }
                }
                .padding(25)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .scaleEffect(animateContent ? 1.0 : 0.8)
                .opacity(animateContent ? 1 : 0)
                
                // Level progress
                VStack(spacing: 10) {
                    HStack {
                        Text("Level \(progressManager.userProgress.level)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.cyan)
                        
                        Spacer()
                        
                        Text("\(progressManager.userProgress.experiencePoints) / \(progressManager.userProgress.experienceToNextLevel) XP")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.cyan, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: geometry.size.width * progressManager.userProgress.experienceProgress)
                        }
                    }
                    .frame(height: 10)
                }
                .padding(.horizontal, 25)
                .opacity(animateContent ? 1 : 0)
                
                // Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        viewModel.restartGame()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20))
                            Text("Play Again")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.cyan, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                        .shadow(color: .cyan.opacity(0.5), radius: 10)
                    }
                    
                    Button(action: onDismiss) {
                        HStack(spacing: 8) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 20))
                            Text("Home")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 25)
                .opacity(animateContent ? 1 : 0)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 30)
            .padding(.horizontal, 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateContent = true
            }
        }
    }
}

struct ScoreRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct AchievementPopup: View {
    let achievement: Achievement
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: achievement.iconName)
                .font(.system(size: 40))
                .foregroundColor(.yellow)
                .scaleEffect(animate ? 1.2 : 0.5)
            
            Text("Achievement Unlocked!")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            Text(achievement.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(achievement.description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                )
        )
        .shadow(color: .yellow.opacity(0.3), radius: 20)
        .padding(.horizontal, 40)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                animate = true
            }
        }
    }
}
