import SwiftUI

struct ProfileView: View {
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
                    VStack(spacing: 25) {
                        // Profile header
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [.cyan, .blue]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: .cyan.opacity(0.5), radius: 20)
                            
                            Text("Level \(progressManager.userProgress.level) Coder")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            // XP Progress
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Experience")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Spacer()
                                    
                                    Text("\(progressManager.userProgress.experiencePoints) / \(progressManager.userProgress.experienceToNextLevel)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.cyan)
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
                                .frame(height: 12)
                            }
                            .padding(.horizontal, 30)
                        }
                        .padding(.top, 30)
                        
                        // Stats grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ProfileStatCard(
                                icon: "star.fill",
                                title: "Total Score",
                                value: "\(progressManager.userProgress.totalScore)",
                                color: .yellow
                            )
                            
                            ProfileStatCard(
                                icon: "questionmark.circle.fill",
                                title: "Questions",
                                value: "\(progressManager.userProgress.totalQuestionsAnswered)",
                                color: .blue
                            )
                            
                            ProfileStatCard(
                                icon: "checkmark.circle.fill",
                                title: "Correct",
                                value: "\(progressManager.userProgress.correctAnswers)",
                                color: .green
                            )
                            
                            ProfileStatCard(
                                icon: "percent",
                                title: "Accuracy",
                                value: String(format: "%.1f%%", progressManager.userProgress.accuracy),
                                color: .cyan
                            )
                            
                            ProfileStatCard(
                                icon: "flame.fill",
                                title: "Current Streak",
                                value: "\(progressManager.userProgress.currentStreak)",
                                color: .orange
                            )
                            
                            ProfileStatCard(
                                icon: "bolt.fill",
                                title: "Longest Streak",
                                value: "\(progressManager.userProgress.longestStreak)",
                                color: .purple
                            )
                            
                            ProfileStatCard(
                                icon: "gamecontroller.fill",
                                title: "Games Played",
                                value: "\(progressManager.userProgress.gamesPlayed)",
                                color: .pink
                            )
                            
                            ProfileStatCard(
                                icon: "trophy.fill",
                                title: "Achievements",
                                value: "\(progressManager.userProgress.unlockedAchievementsCount)",
                                color: .yellow
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Languages played
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Languages Mastered")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            if progressManager.userProgress.languagesPlayed.isEmpty {
                                Text("Start playing to master languages!")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding()
                            } else {
                                FlowLayout(spacing: 10) {
                                    ForEach(Array(progressManager.userProgress.languagesPlayed), id: \.self) { language in
                                        LanguageTag(name: language)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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

struct ProfileStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct LanguageTag: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.cyan.opacity(0.3), .blue.opacity(0.3)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            )
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}
