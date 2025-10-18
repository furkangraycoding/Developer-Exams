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
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 25) {
                // Points Badge
                HStack {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow.opacity(0.5), radius: 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(flashcard.point)")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("POINTS")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(color)
                                .tracking(1.5)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.3), color.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(color.opacity(0.6), lineWidth: 2)
                            )
                    )
                    .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Question Card
                VStack(spacing: 30) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [color.opacity(0.3), color.opacity(0.1), .clear],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 140, height: 140)
                            .blur(radius: 10)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.4), color.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [color.opacity(0.8), color.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            .shadow(color: color.opacity(0.5), radius: 15, x: 0, y: 5)
                        
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    }
                    
                    // Question Text
                    Text(flashcard.question)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .padding(.horizontal, 25)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 35)
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
    let action: () -> Void
    
    var optionLetter: String {
        String(UnicodeScalar(65 + index)!)
    }
    
    var body: some View {
        Button(action: action) {
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
        }
        .buttonStyle(ScaleButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
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

