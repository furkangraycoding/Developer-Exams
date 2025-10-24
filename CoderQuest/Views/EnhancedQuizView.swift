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
    @State private var correctAnswer: String? = nil
    @State private var isAnswerCorrect: Bool? = nil
    
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
                // Top Bar with centered points
                HStack {
                    // Menu Button
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
                    
                    // Center Points Badge
                    if !flashcardViewModel.gameOver && !flashcardViewModel.loadingNewQuestions && flashcardViewModel.currentIndex < flashcardViewModel.currentQuestions.count {
                        let flashcard = flashcardViewModel.currentQuestions[flashcardViewModel.currentIndex]
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.yellow)
                            Text("\(flashcard.point)")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("PTS")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            globalViewModel.chosenMenuColor.opacity(0.4),
                                            globalViewModel.chosenMenuColor.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            globalViewModel.chosenMenuColor.opacity(0.6),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: globalViewModel.chosenMenuColor.opacity(0.4), radius: 8)
                        )
                    }
                    
                    Spacer()
                    
                    // Total Score
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
                        correctAnswer: correctAnswer,
                        isAnswerCorrect: isAnswerCorrect,
                        color: globalViewModel.chosenMenuColor
                    ) { answer in
                        handleAnswer(answer, for: flashcard)
                    }
                }
                
                Spacer()
                
                // Hearts at bottom
                if !flashcardViewModel.gameOver {
                    HStack(spacing: 12) {
                        ForEach(0..<flashcardViewModel.heartsRemaining, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 42))
                                .foregroundColor(.red)
                        }
                        
                        ForEach(0..<(5 - flashcardViewModel.heartsRemaining), id: \.self) { _ in
                            Image(systemName: "heart")
                                .font(.system(size: 42))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                    .padding(.bottom, 20)
                }
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
        .onChange(of: progressManager.recentlyUnlockedAchievements.count) { count in
            // Show popup when achievements are unlocked during gameplay
            if count > 0 && !flashcardViewModel.gameOver {
                print("🎊 New achievement(s) unlocked during gameplay: \(count)")
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showAchievementPopup = true
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
        print("📋 Local chosenMenu parameter: '\(chosenMenu)'")
        print("📋 Global chosenMenu: '\(globalViewModel.chosenMenu)'")
        
        // CRITICAL: Clear achievements first
        showAchievementPopup = false
        progressManager.clearRecentAchievements()
        
        flashcardViewModel.chosenMenu = chosenMenu
        flashcardViewModel.heartsRemaining = 5
        flashcardViewModel.loadFlashcards(chosenMenu: chosenMenu)
        sessionStartTime = Date()
        print("✅ Game setup complete for language: '\(chosenMenu)'")
    }
    
    func handleAnswer(_ answer: String, for flashcard: Flashcard) {
        selectedAnswer = answer
        correctAnswer = flashcard.answer
        
        let isCorrect = answer == flashcard.answer
        isAnswerCorrect = isCorrect
        flashcardViewModel.resultMessage = isCorrect ? "Correct!" : "Try Again"
        flashcardViewModel.showingAnswer = true
        
        questionsInSession += 1
        if isCorrect {
            correctInSession += 1
            progressManager.updateStreak(correct: true)
        } else {
            progressManager.updateStreak(correct: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation {
                flashcardViewModel.showingAnswer = false
                selectedAnswer = nil
                correctAnswer = nil
                isAnswerCorrect = nil
                
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
    let correctAnswer: String?
    let isAnswerCorrect: Bool?
    let color: Color
    let onAnswer: (String) -> Void
    @State private var showQuestion = false
    @State private var pulseAnimation = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Revolutionary Question Card with Particle Effects
                    VStack(spacing: 0) {
                        // Premium content
                        VStack(spacing: 32) {
                            // Ultra premium animated icon at top
                            ZStack {
                                // Rotating outer ring
                                Circle()
                                    .strokeBorder(
                                        AngularGradient(
                                            colors: [color, .clear, color.opacity(0.3), .clear],
                                            center: .center
                                        ),
                                        lineWidth: 1.5
                                    )
                                    .frame(width: 55, height: 55)
                                    .rotationEffect(.degrees(pulseAnimation ? 360 : 0))
                                    .blur(radius: 1)
                                
                                // Multiple glow layers with pulse
                                ForEach(0..<3) { i in
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    color.opacity(0.4 * (1 - Double(i) * 0.3)),
                                                    .clear
                                                ],
                                                center: .center,
                                                startRadius: CGFloat(15 + i * 10),
                                                endRadius: CGFloat(35 + i * 12)
                                            )
                                        )
                                        .frame(width: 70, height: 70)
                                        .blur(radius: 9)
                                }
                                
                                // Main icon circle with shimmer
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    color.opacity(0.35),
                                                    color.opacity(0.2),
                                                    color.opacity(0.3)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 45, height: 45)
                                    
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [color.opacity(0.8), color.opacity(0.4)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .frame(width: 45, height: 45)
                                        .shadow(color: color.opacity(0.6), radius: 9, x: 0, y: 3)
                                    
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(color)
                                        .shadow(color: .black.opacity(0.4), radius: 2)
                                }
                                .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                            }
                            .padding(.top, 20)
                            
                            // Enhanced question text
                            Text(flashcard.question)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(10)
                                .padding(.horizontal, 30)
                                .fixedSize(horizontal: false, vertical: true)
                                .shadow(color: .black.opacity(0.3), radius: 2)
                        }
                        .padding(.vertical, 36)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            // Premium glass card
                            RoundedRectangle(cornerRadius: 34)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(white: 0.16, opacity: 0.96),
                                            Color(white: 0.13, opacity: 0.92),
                                            Color(white: 0.14, opacity: 0.94)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            // Animated border glow
                            RoundedRectangle(cornerRadius: 34)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            color.opacity(0.8),
                                            color.opacity(0.4),
                                            color.opacity(0.6),
                                            color.opacity(0.3),
                                            color.opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3.5
                                )
                        }
                        .shadow(color: color.opacity(0.5), radius: 28, x: 0, y: 14)
                        .shadow(color: .black.opacity(0.4), radius: 18, x: 0, y: 10)
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
                                isSelected: selectedAnswer == choice,
                                isCorrectAnswer: choice == correctAnswer,
                                showResult: selectedAnswer != nil && correctAnswer != nil
                            ) {
                                if selectedAnswer == nil {
                                    onAnswer(choice)
                                }
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
        }
    }
}

struct RevolutionaryChoiceButton: View {
    let text: String
    let index: Int
    let color: Color
    let isSelected: Bool
    let isCorrectAnswer: Bool
    let showResult: Bool
    let action: () -> Void
    
    @State private var shimmerOffset: CGFloat = -200
    
    var optionLetter: String {
        return String(UnicodeScalar(65 + index)!) // A, B, C, D
    }
    
    var buttonColor: Color {
        if showResult {
            if isCorrectAnswer {
                return color // Show correct answer in theme color
            } else if isSelected {
                return Color.gray // Show wrong selection in gray
            }
        }
        return color
    }
    
    var shouldHighlight: Bool {
        if showResult {
            return isCorrectAnswer || isSelected
        }
        return isSelected
    }
    
    // Extract rotating ring to simplify type-checking
    @ViewBuilder
    private var rotatingRing: some View {
        if shouldHighlight {
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [buttonColor, buttonColor.opacity(0.3), buttonColor, buttonColor.opacity(0.3)],
                        center: .center
                    ),
                    lineWidth: 2
                )
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(shouldHighlight ? 360 : 0))
                .animation(
                    Animation.linear(duration: 4.0).repeatForever(autoreverses: false),
                    value: shouldHighlight
                )
                .blur(radius: 1)
        }
    }
    
    // Extract glow layers to simplify type-checking
    @ViewBuilder
    private var glowLayers: some View {
        if shouldHighlight {
            ForEach(0..<3) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                buttonColor.opacity(0.4 - Double(i) * 0.15),
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
    }
    
    // Extract main badge fill to simplify type-checking
    @ViewBuilder
    private var badgeFill: some View {
        if shouldHighlight {
            Circle()
                .fill(
                    AngularGradient(
                        colors: [buttonColor, buttonColor.opacity(0.8), buttonColor, buttonColor.opacity(0.8)],
                        center: .center
                    )
                )
                .frame(width: 52, height: 52)
        } else {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.20),
                            Color.white.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 52, height: 52)
        }
    }
    
    // Extract main badge to simplify type-checking
    private var mainBadge: some View {
        ZStack {
            badgeFill
            
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: shouldHighlight ?
                            [Color.white.opacity(0.5), Color.white.opacity(0.2)] :
                            [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 52, height: 52)
            
            Text(optionLetter)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2)
        }
        .shadow(color: shouldHighlight ? buttonColor.opacity(0.7) : .clear, radius: 16, x: 0, y: 6)
        .scaleEffect(shouldHighlight ? 1.08 : 1.0)
    }
    
    // Extract letter badge to simplify type-checking
    private var letterBadge: some View {
        ZStack {
            rotatingRing
            glowLayers
            mainBadge
        }
    }
    
    // Extract checkmark view to simplify type-checking
    @ViewBuilder
    private var checkmarkView: some View {
        if showResult && isCorrectAnswer {
            ZStack {
                // Pulse effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [buttonColor.opacity(0.4), .clear],
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
                            colors: [buttonColor.opacity(0.3), buttonColor.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 38)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(buttonColor)
                    .shadow(color: buttonColor.opacity(0.6), radius: 6)
            }
            .transition(.scale.combined(with: .opacity))
        } else if showResult && isSelected && !isCorrectAnswer {
            ZStack {
                // Pulse effect for wrong answer
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.gray.opacity(0.4), .clear],
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
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 38)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.gray)
                    .shadow(color: Color.gray.opacity(0.6), radius: 6)
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    // Extract background to simplify type-checking
    private var buttonBackground: some View {
        ZStack {
            // Base glass card
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    shouldHighlight ?
                        LinearGradient(
                            colors: [
                                buttonColor.opacity(0.22),
                                buttonColor.opacity(0.14),
                                buttonColor.opacity(0.18)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color(white: 0.16, opacity: 0.85),
                                Color(white: 0.13, opacity: 0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
            
            // Shimmer effect for selected
            if shouldHighlight {
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
            
            // Premium border with gradient
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    LinearGradient(
                        colors: shouldHighlight ?
                            [
                                buttonColor.opacity(0.9),
                                buttonColor.opacity(0.5),
                                buttonColor.opacity(0.7),
                                buttonColor.opacity(0.4)
                            ] :
                            [
                                Color.white.opacity(0.22),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.15)
                            ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: shouldHighlight ? 3.5 : 2
                )
        }
        .shadow(
            color: shouldHighlight ? buttonColor.opacity(0.6) : Color.black.opacity(0.25),
            radius: shouldHighlight ? 22 : 10,
            x: 0,
            y: shouldHighlight ? 12 : 5
        )
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Revolutionary Letter Badge with Animations
                letterBadge
                
                // Enhanced Answer Text
                Text(text)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: .black.opacity(0.2), radius: 1)
                
                // Animated Checkmark
                checkmarkView
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 22)
            .background(buttonBackground)
        }
        .buttonStyle(RevolutionaryButtonStyle())
        .scaleEffect(shouldHighlight ? 1.04 : 1.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.72), value: shouldHighlight)
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

