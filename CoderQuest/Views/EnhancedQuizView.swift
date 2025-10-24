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
                
                // Hearts at Bottom
                if !flashcardViewModel.gameOver {
                    HStack(spacing: 12) {
                        ForEach(0..<flashcardViewModel.heartsRemaining, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.red)
                                .shadow(color: .red.opacity(0.5), radius: 8)
                        }
                        
                        ForEach(0..<(5 - flashcardViewModel.heartsRemaining), id: \.self) { _ in
                            Image(systemName: "heart")
                                .font(.system(size: 48))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            
            // Achievement Popup - Top of view when game is over
            if showAchievementPopup && !progressManager.recentlyUnlockedAchievements.isEmpty {
                VStack {
                    VStack(spacing: 12) {
                        ForEach(progressManager.recentlyUnlockedAchievements) { achievement in
                            ModernAchievementPopup(achievement: achievement)
                        }
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1000)
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
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 25) {
                // Question Card
                VStack(spacing: 20) {
                    // Question Text
                    Text(flashcard.question)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 25)
                        .padding(.top, 25)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Points Badge at Bottom Right of Card
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.yellow)
                            
                            Text("\(flashcard.point)")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(color.opacity(0.25))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(color.opacity(0.5), lineWidth: 1.5)
                                )
                        )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 15)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(white: 0.15, opacity: 0.95))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [color.opacity(0.6), color.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: color.opacity(0.3), radius: 20, x: 0, y: 10)
                        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                )
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Answer Choices
                VStack(spacing: 15) {
                    ForEach(Array(flashcard.choices.enumerated()), id: \.element) { index, choice in
                        ChoiceButton(
                            text: choice,
                            index: index,
                            color: color,
                            isSelected: selectedAnswer == choice
                        ) {
                            onAnswer(choice)
                        }
                        .opacity(showQuestion ? 1 : 0)
                        .offset(x: showQuestion ? 0 : -30)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(0.1 + Double(index) * 0.08),
                            value: showQuestion
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .opacity(showQuestion ? 1 : 0)
            .scaleEffect(showQuestion ? 1 : 0.95)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showQuestion)
        }
        .onAppear {
            showQuestion = true
        }
    }
}

struct ChoiceButton: View {
    let text: String
    let index: Int
    let color: Color
    let isSelected: Bool
    let isCorrectAnswer: Bool
    let showResult: Bool
    let action: () -> Void
    
    @State private var pulseEffect = false
    
    var optionLetter: String {
        String(UnicodeScalar(65 + index)!)
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
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                pulseEffect = true
            }
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                pulseEffect = false
            }
        }) {
            HStack(spacing: 16) {
                // Letter Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isSelected ? 
                                    [color, color.opacity(0.7)] :
                                    [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.white.opacity(0.4) : Color.white.opacity(0.15),
                            lineWidth: 2
                        )
                        .frame(width: 44, height: 44)
                    
                    Text(optionLetter)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .shadow(color: isSelected ? color.opacity(0.5) : .clear, radius: 8)
                
                // Answer Text
                Text(text)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Check Icon
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(color)
                        .shadow(color: color.opacity(0.5), radius: 6)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ?
                            LinearGradient(
                                colors: [color.opacity(0.25), color.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                isSelected ? 
                                    color.opacity(0.6) :
                                    Color.white.opacity(0.15),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? color.opacity(0.4) : Color.black.opacity(0.2),
                        radius: isSelected ? 15 : 8,
                        x: 0,
                        y: isSelected ? 8 : 4
                    )
            )
            .overlay(
                // Pulse ring animation on selection
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(color, lineWidth: 3)
                    .scaleEffect(pulseEffect ? 1.1 : 1.0)
                    .opacity(pulseEffect ? 0 : (isSelected ? 0.6 : 0))
                    .animation(.easeOut(duration: 0.6), value: pulseEffect)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isSelected)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
struct AnswerFeedbackView: View {
    let isCorrect: Bool
    let color: Color
    
    @State private var scaleEffect: CGFloat = 0.5
    @State private var rotationEffect: Double = -180
    @State private var showParticles = false
    @State private var glowIntensity: Double = 0
    
    var body: some View {
        ZStack {
            // Particle effects for correct answer
            if isCorrect && showParticles {
                ForEach(0..<20) { i in
                    Circle()
                        .fill(
                            [Color.green, Color.yellow, Color.cyan, Color.mint].randomElement() ?? .green
                        )
                        .frame(width: CGFloat.random(in: 8...16), height: CGFloat.random(in: 8...16))
                        .offset(
                            x: CGFloat.random(in: -200...200),
                            y: CGFloat.random(in: -200...200)
                        )
                        .opacity(showParticles ? 0 : 1)
                        .animation(
                            .easeOut(duration: Double.random(in: 0.8...1.2))
                                .delay(Double(i) * 0.02),
                            value: showParticles
                        )
                }
            }
            
            VStack(spacing: 30) {
                // Animated Icon with Glow
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    isCorrect ? Color.green.opacity(glowIntensity) : Color.red.opacity(glowIntensity),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    // Icon
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(isCorrect ? .green : .red)
                        .shadow(color: isCorrect ? Color.green.opacity(0.6) : Color.red.opacity(0.6), radius: 20)
                        .scaleEffect(scaleEffect)
                        .rotationEffect(.degrees(isCorrect ? rotationEffect : 0))
                }
                
                // Text with background
                Text(isCorrect ? "Correct!" : "Try Again!")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: isCorrect ? 
                                        [Color.green.opacity(0.3), Color.mint.opacity(0.2)] :
                                        [Color.red.opacity(0.3), Color.orange.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        isCorrect ? Color.green.opacity(0.6) : Color.red.opacity(0.6),
                                        lineWidth: 3
                                    )
                            )
                    )
                    .shadow(color: isCorrect ? Color.green.opacity(0.4) : Color.red.opacity(0.4), radius: 15)
                    .scaleEffect(scaleEffect)
            }
        }
        .onAppear {
            // Entrance animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scaleEffect = 1.0
                if isCorrect {
                    rotationEffect = 0
                }
            }
            
            // Glow pulse
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                glowIntensity = 0.6
            }
            
            // Show particles for correct answer
            if isCorrect {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showParticles = true
                }
            }
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

