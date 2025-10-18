import SwiftUI

struct MainMenuView: View {
    @StateObject private var progressManager = ProgressManager.shared
    @State private var showProfile = false
    @State private var showAchievements = false
    @State private var showLeaderboard = false
    @State private var showSettings = false
    @State private var selectedLanguage: String?
    @State private var animateGradient = false
    @State private var isLoaded = false
    
    let languages = [
        ("Swift", Color.orange, "swift"),
        ("Python", Color.blue, "arrow.triangle.2.circlepath"),
        ("JavaScript", Color.yellow, "curlybraces"),
        ("Java", Color.red, "cup.and.saucer.fill"),
        ("Ruby", Color(red: 0.8, green: 0.2, blue: 0.2), "gem"),
        ("C#", Color.purple, "number"),
        ("Go", Color.cyan, "hare.fill"),
        ("Solidity", Color.pink, "link.circle.fill")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.3),
                        Color(red: 0.1, green: 0.2, blue: 0.3)
                    ]),
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
                .onAppear {
                    print("📱 MainMenuView appeared")
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                    isLoaded = true
                }
                
                // Floating particles
                if isLoaded {
                    ParticlesView()
                }
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header with user info
                        headerView
                        
                        // Stats card
                        statsCardView
                        
                        // Languages grid
                        languagesGridView
                        
                        // Quick actions
                        quickActionsView
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView()
            }
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .fullScreenCover(item: $selectedLanguage) { language in
                QuizGameView(language: language)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("CoderQuest")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Level \(progressManager.userProgress.level)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.cyan)
            }
            
            Spacer()
            
            Button(action: { showProfile = true }) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.cyan, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .shadow(color: .cyan.opacity(0.5), radius: 10)
            }
        }
        .padding(.horizontal)
    }
    
    private var statsCardView: some View {
        VStack(spacing: 15) {
            // XP Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Experience")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(progressManager.userProgress.experiencePoints) / \(progressManager.userProgress.experienceToNextLevel)")
                        .font(.system(size: 12, weight: .medium))
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
            
            // Stats grid
            HStack(spacing: 15) {
                StatBox(
                    icon: "flame.fill",
                    value: "\(progressManager.userProgress.currentStreak)",
                    label: "Streak",
                    color: .orange
                )
                
                StatBox(
                    icon: "star.fill",
                    value: "\(progressManager.userProgress.totalScore)",
                    label: "Score",
                    color: .yellow
                )
                
                StatBox(
                    icon: "checkmark.circle.fill",
                    value: String(format: "%.0f%%", progressManager.userProgress.accuracy),
                    label: "Accuracy",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20)
    }
    
    private var languagesGridView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Choose Your Language")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15)
            ], spacing: 15) {
                ForEach(languages, id: \.0) { language in
                    LanguageCard(
                        name: language.0,
                        color: language.1,
                        icon: language.2
                    ) {
                        withAnimation(.spring()) {
                            selectedLanguage = language.0
                        }
                    }
                }
            }
        }
    }
    
    private var quickActionsView: some View {
        VStack(spacing: 12) {
            QuickActionButton(
                icon: "trophy.fill",
                title: "Achievements",
                color: .yellow
            ) {
                showAchievements = true
            }
            
            QuickActionButton(
                icon: "chart.bar.fill",
                title: "Leaderboard",
                color: .green
            ) {
                showLeaderboard = true
            }
            
            QuickActionButton(
                icon: "gearshape.fill",
                title: "Settings",
                color: .gray
            ) {
                showSettings = true
            }
        }
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct LanguageCard: View {
    let name: String
    let color: Color
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundColor(color)
                }
                
                Text(name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.1),
                                color.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color.opacity(0.3), lineWidth: 2)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: color.opacity(0.3), radius: isPressed ? 5 : 15)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 40)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ParticlesView: View {
    @State private var particles: [ParticleModel] = []
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                print("🎨 Generating particles...")
                generateParticles(in: geometry.size)
                startAnimating(in: geometry.size)
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
        }
        .ignoresSafeArea()
    }
    
    private func generateParticles(in size: CGSize) {
        guard size.width > 0 && size.height > 0 else { return }
        
        particles.removeAll()
        for _ in 0..<15 {
            particles.append(ParticleModel(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 2...5),
                color: [Color.cyan, Color.blue, Color.purple].randomElement()!,
                opacity: Double.random(in: 0.1...0.3)
            ))
        }
    }
    
    private func startAnimating(in size: CGSize) {
        guard size.width > 0 && size.height > 0 else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [self] _ in
            guard !particles.isEmpty else { return }
            
            for index in particles.indices {
                particles[index].position.y -= CGFloat.random(in: 0.5...1.5)
                particles[index].position.x += CGFloat.random(in: -0.5...0.5)
                
                if particles[index].position.y < 0 {
                    particles[index].position.y = size.height
                    particles[index].position.x = CGFloat.random(in: 0...size.width)
                }
            }
        }
    }
}

struct ParticleModel: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
}

extension String: Identifiable {
    public var id: String { self }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
