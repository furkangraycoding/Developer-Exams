//
//  EnhancedQuizView.swift
//  CoderQuest
//
//  Enhanced Quiz View with Timer, Progress Bar, and Difficulty Modes
//

import SwiftUI

struct EnhancedQuizView: View {
    var username: String = ""
    var chosenMenu: String = ""
    
    @StateObject private var flashcardViewModel: FlashcardViewModel
    @StateObject var interstitialAdsManager = InterstitialAdsManager()
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @ObservedObject var progressManager = ProgressManager.shared
    
    @State private var showGameOver = false
    @State private var showVictoryAnimation = false
    @State private var questionsInSession = 0
    @State private var correctInSession = 0
    @State private var sessionStartTime = Date()
    @State private var selectedAnswer: String? = nil
    @State private var showAchievementPopup = false
    
    init(username: String, chosenMenu: String) {
        self.username = username
        self.chosenMenu = chosenMenu
        _flashcardViewModel = StateObject(wrappedValue: FlashcardViewModel())
    }
    
    var body: some View {
        ZStack {
            // Enhanced Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black.opacity(0.9),
                    globalViewModel.chosenMenuColor.opacity(0.25),
                    globalViewModel.chosenMenuColor.opacity(0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {
                        globalViewModel.isMenuVisible = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                            Text("Menu")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .shadow(color: globalViewModel.chosenMenuColor.opacity(0.3), radius: 5)
                        )
                    }
                    
                    Spacer()
                    
                    // Score
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                        Text("\(flashcardViewModel.correctAnswersCount)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .shadow(color: .yellow.opacity(0.3), radius: 5)
                    )
                    
                }
                .padding()
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [globalViewModel.chosenMenuColor, globalViewModel.chosenMenuColor.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                            .animation(.spring(), value: progress)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal)
                
                // Hearts
                if !flashcardViewModel.gameOver {
                    HStack(spacing: 8) {
                        ForEach(0..<flashcardViewModel.heartsRemaining, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        
                        ForEach(0..<(5 - flashcardViewModel.heartsRemaining), id: \.self) { _ in
                            Image(systemName: "heart")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                Spacer()
                
                // Main Content
                if flashcardViewModel.gameOver {
                    GameOverView(
                        score: flashcardViewModel.correctAnswersCount,
                        questionsAnswered: questionsInSession,
                        correctAnswers: correctInSession,
                        language: chosenMenu,
                        color: globalViewModel.chosenMenuColor
                    ) {
                        restartGame()
                    } onWatchAd: {
                        flashcardViewModel.restoreHearts()
                        showAd()
                    }
                } else if flashcardViewModel.loadingNewQuestions {
                    LoadingView(color: globalViewModel.chosenMenuColor)
                } else if flashcardViewModel.showingAnswer {
                    AnswerFeedbackView(
                        isCorrect: flashcardViewModel.resultMessage == "Correct!",
                        color: globalViewModel.chosenMenuColor
                    )
                } else if flashcardViewModel.currentIndex < flashcardViewModel.currentQuestions.count {
                    let flashcard = flashcardViewModel.currentQuestions[flashcardViewModel.currentIndex]
                    
                    QuestionView(
                        flashcard: flashcard,
                        selectedAnswer: $selectedAnswer,
                        color: globalViewModel.chosenMenuColor
                    ) { answer in
                        handleAnswer(answer, for: flashcard)
                    }
                }
                
                Spacer()
            }
            
            // Achievement Popup - Only show if we have NEW achievements
            if showAchievementPopup && !progressManager.recentlyUnlockedAchievements.isEmpty {
                VStack(spacing: 12) {
                    ForEach(progressManager.recentlyUnlockedAchievements) { achievement in
                        ModernAchievementPopup(achievement: achievement)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1000) // Ensure it's on top
                .onAppear {
                    let count = progressManager.recentlyUnlockedAchievements.count
                    print("🎯 Displaying \(count) achievement popup(s)")
                    
                    // Auto-hide after 4 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                        print("⏰ Auto-hiding achievement popup")
                        withAnimation(.easeOut(duration: 0.4)) {
                            showAchievementPopup = false
                        }
                        // Clear after animation completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            progressManager.clearRecentAchievements()
                        }
                    }
                }
            }
        }
        .onAppear {
            setupGame()
        }
        .onChange(of: flashcardViewModel.gameOver) { isGameOver in
            if isGameOver {
                print("💀 Game Over detected")
                
                // STEP 1: Immediately hide any visible popups
                showAchievementPopup = false
                
                // STEP 2: Clear old achievements with proper method
                progressManager.clearRecentAchievements()
                
                // STEP 3: Record the session (this will check and unlock new achievements)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    print("📊 Recording game session...")
                    self.recordGameSession()
                    
                    // STEP 4: Show ONLY newly unlocked achievements
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let count = self.progressManager.recentlyUnlockedAchievements.count
                        print("📋 Checking achievements: \(count) new")
                        
                        if count > 0 {
                            print("🎊 Showing \(count) NEW achievement(s)")
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                self.showAchievementPopup = true
                            }
                        } else {
                            print("✅ No new achievements unlocked this session")
                        }
                    }
                }
            }
        }
    }
    
    var progress: Double {
        guard flashcardViewModel.currentQuestions.count > 0 else { return 0 }
        return Double(flashcardViewModel.currentIndex) / Double(flashcardViewModel.currentQuestions.count)
    }
    
    func setupGame() {
        print("🎮 Setting up new game")
        // CRITICAL: Clear achievements first
        showAchievementPopup = false
        progressManager.clearRecentAchievements()
        
        flashcardViewModel.chosenMenu = chosenMenu
        flashcardViewModel.heartsRemaining = 5
        flashcardViewModel.loadFlashcards(chosenMenu: chosenMenu)
        sessionStartTime = Date()
        print("✅ Game setup complete")
    }
    
    func handleAnswer(_ answer: String, for flashcard: Flashcard) {
        selectedAnswer = answer
        
        let isCorrect = answer == flashcard.answer
        flashcardViewModel.resultMessage = isCorrect ? "Correct!" : "Try Again"
        flashcardViewModel.showingAnswer = true
        
        questionsInSession += 1
        if isCorrect {
            correctInSession += 1
            progressManager.updateStreak(correct: true)
        } else {
            progressManager.updateStreak(correct: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                flashcardViewModel.showingAnswer = false
                selectedAnswer = nil
                
                if isCorrect {
                    flashcardViewModel.correctAnswersCount += flashcard.point
                } else {
                    flashcardViewModel.heartsRemaining -= 1
                    
                    if flashcardViewModel.heartsRemaining <= 0 {
                        flashcardViewModel.gameOver = true
                        return
                    }
                }
                
                flashcardViewModel.currentIndex += 1
                
                if flashcardViewModel.currentIndex >= flashcardViewModel.currentQuestions.count {
                    flashcardViewModel.loadNewQuestions()
                }
            }
        }
    }
    
    func recordGameSession() {
        let timePlayed = Date().timeIntervalSince(sessionStartTime)
        let isPerfect = correctInSession == questionsInSession && questionsInSession > 0
        
        // Record session - this will populate recentlyUnlockedAchievements
        progressManager.recordGameSession(
            language: chosenMenu,
            score: flashcardViewModel.correctAnswersCount,
            questionsAnswered: questionsInSession,
            correctAnswers: correctInSession,
            difficulty: .easy,
            timePlayed: timePlayed,
            isPerfect: isPerfect
        )
    }
    
    func restartGame() {
        print("🔄 Restarting game")
        // Clear achievements completely
        showAchievementPopup = false
        progressManager.clearRecentAchievements()
        
        flashcardViewModel.restartGame()
        questionsInSession = 0
        correctInSession = 0
        sessionStartTime = Date()
        print("✅ Game restarted")
    }
    
    func showAd() {
        interstitialAdsManager.displayInterstitialAd()
    }
}

// MARK: - Supporting Views

struct QuestionView: View {
    let flashcard: Flashcard
    @Binding var selectedAnswer: String?
    let color: Color
    let onAnswer: (String) -> Void
    @State private var showQuestion = false
    @State private var pulseAnimation = false
    @State private var floatAnimation = false
    @State private var glowIntensity: Double = 0.3
    @State private var shimmerPhase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Premium Points Badge with Particle Effects
                    HStack {
                        Spacer()
                        
                        ZStack {
                            // Dynamic pulsing glow layers
                            ForEach(0..<4) { i in
                                Capsule()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                color.opacity(glowIntensity * (1.0 - Double(i) * 0.15)),
                                                color.opacity(glowIntensity * 0.3),
                                                .clear
                                            ],
                                            center: .center,
                                            startRadius: CGFloat(10 + i * 8),
                                            endRadius: CGFloat(35 + i * 12)
                                        )
                                    )
                                    .frame(height: CGFloat(60 + i * 6))
                                    .blur(radius: CGFloat(10 + i * 3))
                                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 1.8 + Double(i) * 0.3)
                                            .repeatForever(autoreverses: true)
                                            .delay(Double(i) * 0.15),
                                        value: pulseAnimation
                                    )
                            }
                            
                            HStack(spacing: 14) {
                                // Animated star with shimmer
                                ZStack {
                                    // Outer glow ring
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [.yellow.opacity(0.7), .orange.opacity(0.4), .clear],
                                                center: .center,
                                                startRadius: 8,
                                                endRadius: 32
                                            )
                                        )
                                        .frame(width: 56, height: 56)
                                        .blur(radius: 10)
                                    
                                    // Rotating gradient circle
                                    Circle()
                                        .fill(
                                            AngularGradient(
                                                colors: [
                                                    .yellow,
                                                    .orange,
                                                    .red.opacity(0.8),
                                                    .orange,
                                                    .yellow
                                                ],
                                                center: .center,
                                                startAngle: .degrees(shimmerPhase),
                                                endAngle: .degrees(shimmerPhase + 360)
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                        .shadow(color: .yellow.opacity(0.9), radius: 12)
                                    
                                    // Inner white circle for contrast
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.4), radius: 2)
                                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(flashcard.point)")
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.white, .white.opacity(0.9)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 2)
                                    Text("POINTS")
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundColor(color.opacity(0.9))
                                        .tracking(2)
                                        .shadow(color: .black.opacity(0.3), radius: 1)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                ZStack {
                                    // Glossy base
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.25),
                                                    color.opacity(0.45),
                                                    color.opacity(0.35),
                                                    color.opacity(0.5)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // Glass reflection effect
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.4),
                                                    .clear,
                                                    .clear
                                                ],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )
                                        .frame(height: 28)
                                        .offset(y: -7)
                                    
                                    // Premium border
                                    Capsule()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.8),
                                                    color.opacity(0.9),
                                                    color,
                                                    color.opacity(0.7),
                                                    .white.opacity(0.6)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3.5
                                        )
                                }
                                .shadow(color: color.opacity(0.7), radius: 18, x: 0, y: 8)
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .offset(y: floatAnimation ? -6 : 0)
                        .scaleEffect(floatAnimation ? 1.02 : 1.0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    .padding(.bottom, 38)
                    
                    // Enhanced Question Card
                    VStack(spacing: 0) {
                        // Premium header
                        VStack(spacing: 0) {
                            HStack(spacing: 14) {
                                // Animated status indicator
                                HStack(spacing: 8) {
                                    ForEach(0..<3) { i in
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [color, color.opacity(0.7)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 10, height: 10)
                                            .shadow(color: color.opacity(0.9), radius: 5)
                                            .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                                            .opacity(pulseAnimation ? 1.0 : 0.7)
                                            .animation(
                                                Animation.easeInOut(duration: 1.0)
                                                    .repeatForever(autoreverses: true)
                                                    .delay(Double(i) * 0.25),
                                                value: pulseAnimation
                                            )
                                    }
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(color)
                                    Text("QUESTION")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundColor(color)
                                        .tracking(2.5)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [color.opacity(0.25), color.opacity(0.15)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(color.opacity(0.5), lineWidth: 1.5)
                                        )
                                )
                            }
                            .padding(.horizontal, 28)
                            .padding(.top, 24)
                            .padding(.bottom, 16)
                            
                            // Animated divider
                            GeometryReader { geo in
                                LinearGradient(
                                    colors: [.clear, color.opacity(0.5), color, color.opacity(0.5), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(height: 2)
                                .mask(
                                    Rectangle()
                                        .frame(width: geo.size.width * (showQuestion ? 1.0 : 0.0))
                                        .animation(.easeOut(duration: 0.8).delay(0.3), value: showQuestion)
                                )
                            }
                            .frame(height: 2)
                            .padding(.horizontal, 26)
                        }
                        
                        // Premium content
                        VStack(spacing: 36) {
                            // Enhanced animated icon with depth
                            ZStack {
                                // Outer rotating rings
                                ForEach(0..<2) { ringIndex in
                                    Circle()
                                        .strokeBorder(
                                            AngularGradient(
                                                colors: [
                                                    color.opacity(0.8),
                                                    .clear,
                                                    color.opacity(0.4),
                                                    .clear,
                                                    color.opacity(0.6),
                                                    .clear
                                                ],
                                                center: .center
                                            ),
                                            lineWidth: 2.5
                                        )
                                        .frame(width: CGFloat(118 + ringIndex * 12), height: CGFloat(118 + ringIndex * 12))
                                        .rotationEffect(.degrees(pulseAnimation ? (ringIndex % 2 == 0 ? 360 : -360) : 0))
                                        .blur(radius: 1.5)
                                        .opacity(0.7)
                                }
                                
                                // Multi-layer glows with breathing effect
                                ForEach(0..<4) { i in
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    color.opacity(glowIntensity * (0.9 - Double(i) * 0.2)),
                                                    color.opacity(glowIntensity * 0.3),
                                                    .clear
                                                ],
                                                center: .center,
                                                startRadius: CGFloat(25 + i * 15),
                                                endRadius: CGFloat(60 + i * 20)
                                            )
                                        )
                                        .frame(width: CGFloat(140 + i * 10), height: CGFloat(140 + i * 10))
                                        .blur(radius: CGFloat(15 + i * 3))\n                                        .scaleEffect(pulseAnimation ? 1.03 : 1.0)
                                        .animation(\n                                            Animation.easeInOut(duration: 2.0 + Double(i) * 0.3)\n                                                .repeatForever(autoreverses: true)\n                                                .delay(Double(i) * 0.15),\n                                            value: pulseAnimation\n                                        )
                                }
                                
                                // Main icon circle with glass effect
                                ZStack {
                                    // Base gradient circle
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    color.opacity(0.5),
                                                    color.opacity(0.3),
                                                    color.opacity(0.4)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                    
                                    // Glass reflection
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.3),
                                                    .clear
                                                ],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                    
                                    // Border with gradient
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.6),
                                                    color.opacity(0.9),
                                                    color.opacity(0.6),
                                                    .white.opacity(0.4)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 4.5
                                        )
                                        .frame(width: 100, height: 100)
                                        .shadow(color: color.opacity(0.7), radius: 20, x: 0, y: 8)
                                    
                                    // Icon with enhanced styling
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 46, weight: .bold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.white, color.opacity(0.9)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                                        .shadow(color: color.opacity(0.8), radius: 8)
                                }
                                .scaleEffect(pulseAnimation ? 1.06 : 1.0)
                            }
                            .padding(.top, 18)
                            
                            // Premium question text with background
                            VStack(spacing: 16) {
                                Text(flashcard.question)
                                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .white.opacity(0.95)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(11)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 20)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.08),
                                                        Color.white.opacity(0.04)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 18)
                                                    .strokeBorder(
                                                        Color.white.opacity(0.15),
                                                        lineWidth: 1.5
                                                    )
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.vertical, 40)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            // Premium glass card with depth
                            RoundedRectangle(cornerRadius: 36)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(white: 0.18, opacity: 0.97),
                                            Color(white: 0.14, opacity: 0.94),
                                            Color(white: 0.15, opacity: 0.96),
                                            Color(white: 0.13, opacity: 0.93)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            // Top glass reflection
                            RoundedRectangle(cornerRadius: 36)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.12),
                                            .clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                            
                            // Enhanced animated border
                            RoundedRectangle(cornerRadius: 36)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.4),
                                            color.opacity(0.85),
                                            color.opacity(0.5),
                                            color.opacity(0.7),
                                            color.opacity(0.4),
                                            .white.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 4
                                )
                        }
                        .shadow(color: color.opacity(0.6), radius: 32, x: 0, y: 16)
                        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 12)
                        .shadow(color: color.opacity(0.3), radius: 15, x: 0, y: 8)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .opacity(showQuestion ? 1 : 0)
                    .offset(y: showQuestion ? 0 : -40)
                    .scaleEffect(showQuestion ? 1 : 0.92)
                    .rotationEffect(.degrees(showQuestion ? 0 : -3))
                    .animation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.2), value: showQuestion)
                    
                    // Revolutionary Answer Choices with Effects
                    VStack(spacing: 18) {
                        ForEach(Array(flashcard.choices.enumerated()), id: \.element) { index, choice in
                            RevolutionaryChoiceButton(
                                text: choice,
                                index: index,
                                color: color,
                                isSelected: selectedAnswer == choice
                            ) {
                                onAnswer(choice)
                            }
                            .opacity(showQuestion ? 1 : 0)
                            .offset(x: showQuestion ? 0 : -50)
                            .scaleEffect(showQuestion ? 1 : 0.88)
                            .rotationEffect(.degrees(showQuestion ? 0 : -5))
                            .animation(
                                .spring(response: 0.8, dampingFraction: 0.72)
                                    .delay(0.35 + Double(index) * 0.1),
                                value: showQuestion
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .onAppear {
            showQuestion = true
            
            // Star rotation animation
            withAnimation(Animation.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                pulseAnimation = true
            }
            
            // Floating animation
            withAnimation(Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                floatAnimation = true
            }
            
            // Glow intensity animation
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowIntensity = 0.5
            }
            
            // Shimmer rotation animation
            withAnimation(Animation.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                shimmerPhase = 360
            }
        }
    }
}

struct RevolutionaryChoiceButton: View {
    let text: String
    let index: Int
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var shimmerOffset: CGFloat = -200
    
    var optionLetter: String {
        return String(UnicodeScalar(65 + index)!) // A, B, C, D
    }
    
    // Break down complex gradients into separate properties
    private var selectedBadgeFill: some ShapeStyle {
        AngularGradient(
            colors: [color, color.opacity(0.8), color, color.opacity(0.8)],
            center: .center
        )
    }
    
    private var unselectedBadgeFill: some ShapeStyle {
        LinearGradient(
            colors: [
                Color.white.opacity(0.20),
                Color.white.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var badgeFill: some ShapeStyle {
        isSelected ? AnyShapeStyle(selectedBadgeFill) : AnyShapeStyle(unselectedBadgeFill)
    }
    
    private var selectedBackgroundFill: some ShapeStyle {
        LinearGradient(
            colors: [
                color.opacity(0.22),
                color.opacity(0.14),
                color.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var unselectedBackgroundFill: some ShapeStyle {
        LinearGradient(
            colors: [
                Color(white: 0.16, opacity: 0.85),
                Color(white: 0.13, opacity: 0.75)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var backgroundFill: some ShapeStyle {
        isSelected ? AnyShapeStyle(selectedBackgroundFill) : AnyShapeStyle(unselectedBackgroundFill)
    }
    
    var body: some View {
        Button(action: action) {
            buttonContent
        }
        .buttonStyle(RevolutionaryButtonStyle())
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.72), value: isSelected)
    }
    
    private var buttonContent: some View {
        HStack(spacing: 20) {
            letterBadge
            answerText
            if isSelected {
                checkmark
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 22)
        .background(cardBackground)
    }
    
    private var letterBadge: some View {
        ZStack {
            if isSelected {
                outerRotatingRing
                multiLayerGlow
            }
            mainBadge
        }
    }
    
    private var outerRotatingRing: some View {
        Circle()
            .strokeBorder(
                AngularGradient(
                    colors: [color, color.opacity(0.3), color, color.opacity(0.3)],
                    center: .center
                ),
                lineWidth: 2
            )
            .frame(width: 64, height: 64)
            .rotationEffect(.degrees(isSelected ? 360 : 0))
            .animation(
                Animation.linear(duration: 4.0).repeatForever(autoreverses: false),
                value: isSelected
            )
            .blur(radius: 1)
    }
    
    private var multiLayerGlow: some View {
        ForEach(0..<3) { i in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.4 - Double(i) * 0.15),
                            .clear
                        ],
                        center: .center,
                        startRadius: CGFloat(18 + i * 12),
                        endRadius: CGFloat(35 + i * 15)
                    )
                )
                .frame(width: 60, height: 60)
                .blur(radius: 12)
        }
    }
    
    private var mainBadge: some View {
        ZStack {
            Circle()
                .fill(badgeFill)
                .frame(width: 52, height: 52)
            
            Circle()
                .strokeBorder(badgeStroke, lineWidth: 3)
                .frame(width: 52, height: 52)
            
            Text(optionLetter)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2)
        }
        .shadow(color: isSelected ? color.opacity(0.7) : .clear, radius: 16, x: 0, y: 6)
        .scaleEffect(isSelected ? 1.08 : 1.0)
    }
    
    private var badgeStroke: some ShapeStyle {
        let selectedColors = [Color.white.opacity(0.5), Color.white.opacity(0.2)]
        let unselectedColors = [Color.white.opacity(0.2), Color.white.opacity(0.05)]
        
        return LinearGradient(
            colors: isSelected ? selectedColors : unselectedColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var answerText: some View {
        Text(text)
            .font(.system(size: 17, weight: isSelected ? .semibold : .medium))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .lineSpacing(5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .shadow(color: .black.opacity(0.2), radius: 1)
    }
    
    private var checkmark: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.4), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 25
                    )
                )
                .frame(width: 42, height: 42)
                .blur(radius: 8)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.3), color.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 38, height: 38)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.6), radius: 6)
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(backgroundFill)
            
            if isSelected {
                shimmerEffect
            }
            
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(borderGradient, lineWidth: isSelected ? 3.5 : 2)
        }
        .shadow(
            color: isSelected ? color.opacity(0.6) : Color.black.opacity(0.25),
            radius: isSelected ? 22 : 10,
            x: 0,
            y: isSelected ? 12 : 5
        )
    }
    
    private var shimmerEffect: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        Color.white.opacity(0.15),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .offset(x: shimmerOffset)
            .mask(RoundedRectangle(cornerRadius: 24))
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 2.0)
                        .repeatForever(autoreverses: false)
                ) {
                    shimmerOffset = 400
                }
            }
    }
    
    private var borderGradient: some ShapeStyle {
        let selectedColors = [
            color.opacity(0.9),
            color.opacity(0.5),
            color.opacity(0.7),
            color.opacity(0.4)
        ]
        let unselectedColors = [
            Color.white.opacity(0.22),
            Color.white.opacity(0.08),
            Color.white.opacity(0.15)
        ]
        
        return LinearGradient(
            colors: isSelected ? selectedColors : unselectedColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct RevolutionaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

struct AnswerFeedbackView: View {
    let isCorrect: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(isCorrect ? .green : .red)
                .scaleEffect(1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isCorrect)
            
            Text(isCorrect ? "Correct!" : "Try Again!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct LoadingView: View {
    let color: Color
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(color)
            
            Text("Loading new questions...")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct GameOverView: View {
    let score: Int
    let questionsAnswered: Int
    let correctAnswers: Int
    let language: String
    let color: Color
    let onRestart: () -> Void
    let onWatchAd: () -> Void
    
    @ObservedObject var progressManager = ProgressManager.shared
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered) * 100
    }
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Game Over!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Score Card
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading) {
                        Text("Score")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(score)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                HStack(spacing: 30) {
                    VStack {
                        Text("\(questionsAnswered)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Questions")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    VStack {
                        Text(String(format: "%.0f%%", accuracy))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Accuracy")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .shadow(color: color.opacity(0.3), radius: 10)
            )
            .padding(.horizontal)
            
            // Action Buttons
            HStack(spacing: 20) {
                Button(action: onRestart) {
                    VStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 30))
                        Text("Restart")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(color.opacity(0.6))
                            .shadow(color: color.opacity(0.4), radius: 8)
                    )
                }
                
                Button(action: onWatchAd) {
                    VStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 30))
                        Text("Continue")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.red.opacity(0.6))
                            .shadow(color: .red.opacity(0.4), radius: 8)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ModernAchievementPopup: View {
    let achievement: Achievement
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var rotation: Double = -10
    
    var achievementColor: (primary: Color, secondary: Color) {
        switch achievement.type {
        case .firstWin, .perfectScore:
            return (.green, .mint)
        case .streak5, .streak10, .streak20, .streak50:
            return (.orange, .yellow)
        case .speed50, .speed100, .speed250, .speed500:
            return (.blue, .cyan)
        case .allLanguages:
            return (.purple, .pink)
        case .hardMode:
            return (.red, .orange)
        case .master100, .master500, .master1000, .master2500, .master5000:
            return (.yellow, .orange)
        case .nightOwl, .earlyBird, .weekendWarrior:
            return (.indigo, .purple)
        case .marathonRunner, .centuryClub:
            return (.green, .teal)
        case .perfectStreak:
            return (.pink, .purple)
        case .speedDemon:
            return (.cyan, .blue)
        case .dedicated, .veteran:
            return (.orange, .red)
        case .legend:
            return (.yellow, .pink)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Animated Icon
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [achievementColor.primary.opacity(0.6), .clear],
                            center: .center,
                            startRadius: 15,
                            endRadius: 40
                        )
                    )
                    .frame(width: 70, height: 70)
                    .blur(radius: 10)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [achievementColor.primary, achievementColor.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                    )
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
            }
            .rotationEffect(.degrees(rotation))
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundColor(achievementColor.primary)
                    Text("ACHIEVEMENT UNLOCKED")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(achievementColor.primary)
                }
                
                Text(achievement.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text("+\(achievement.xpReward) XP")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.95),
                                Color.black.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [achievementColor.primary, achievementColor.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            }
            .shadow(color: achievementColor.primary.opacity(0.6), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 20)
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
                rotation = 0
            }
        }
    }
}

