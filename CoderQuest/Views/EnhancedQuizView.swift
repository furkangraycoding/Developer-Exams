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
            
            // Achievement Popup
            if showAchievementPopup && !progressManager.recentlyUnlockedAchievements.isEmpty {
                AchievementPopupView(achievements: progressManager.recentlyUnlockedAchievements)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showAchievementPopup = false
                                progressManager.recentlyUnlockedAchievements.removeAll()
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
                // First clear old achievements
                showAchievementPopup = false
                progressManager.recentlyUnlockedAchievements.removeAll()
                
                // Then record session (which will add new achievements)
                recordGameSession()
                
                // Show only new achievements after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if !progressManager.recentlyUnlockedAchievements.isEmpty {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showAchievementPopup = true
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
        // Clear any old achievements first
        showAchievementPopup = false
        progressManager.recentlyUnlockedAchievements.removeAll()
        
        flashcardViewModel.chosenMenu = chosenMenu
        flashcardViewModel.heartsRemaining = 5
        flashcardViewModel.loadFlashcards(chosenMenu: chosenMenu)
        sessionStartTime = Date()
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
        // Clear achievements and reset
        showAchievementPopup = false
        progressManager.recentlyUnlockedAchievements.removeAll()
        
        flashcardViewModel.restartGame()
        questionsInSession = 0
        correctInSession = 0
        sessionStartTime = Date()
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
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top Section - Points Badge
                    HStack {
                        Spacer()
                        
                        ZStack {
                            // Glow effect
                            Capsule()
                                .fill(
                                    RadialGradient(
                                        colors: [color.opacity(0.4), .clear],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 40
                                    )
                                )
                                .frame(height: 44)
                                .blur(radius: 8)
                            
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                }
                                
                                Text("\(flashcard.point)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("points")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [color.opacity(0.3), color.opacity(0.15)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [color, color.opacity(0.5)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 25)
                    
                    // Question Card with Modern Design
                    VStack(spacing: 0) {
                        // Decorative top bar
                        HStack(spacing: 8) {
                            Circle()
                                .fill(color.opacity(0.8))
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(color.opacity(0.6))
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(color.opacity(0.4))
                                .frame(width: 8, height: 8)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 15)
                        .padding(.bottom, 20)
                        
                        // Question content
                        VStack(spacing: 25) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [color.opacity(0.25), .clear],
                                            center: .center,
                                            startRadius: 30,
                                            endRadius: 70
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .blur(radius: 12)
                                
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [color.opacity(0.3), color.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Circle()
                                            .stroke(color.opacity(0.5), lineWidth: 2)
                                    )
                                
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundColor(color)
                            }
                            
                            // Question text
                            Text(flashcard.question)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .padding(.horizontal, 25)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.bottom, 30)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.12),
                                            Color.white.opacity(0.08)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    LinearGradient(
                                        colors: [color.opacity(0.6), color.opacity(0.2), color.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        }
                        .shadow(color: color.opacity(0.35), radius: 20, x: 0, y: 10)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .opacity(showQuestion ? 1 : 0)
                    .offset(y: showQuestion ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showQuestion)
                    
                    // Answer Choices
                    VStack(spacing: 14) {
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
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2 + Double(index) * 0.1), value: showQuestion)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .frame(minHeight: geometry.size.height)
            }
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
        return String(UnicodeScalar(65 + index)!) // A, B, C, D
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Enhanced Option letter badge
                ZStack {
                    // Outer glow for selected
                    if isSelected {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [color.opacity(0.4), .clear],
                                    center: .center,
                                    startRadius: 15,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 50, height: 50)
                            .blur(radius: 8)
                    }
                    
                    Circle()
                        .fill(
                            isSelected ?
                                LinearGradient(
                                    colors: [color, color.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.white.opacity(0.15), Color.white.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1),
                                    lineWidth: 2
                                )
                        )
                    
                    Text(optionLetter)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Enhanced Answer text
                Text(text)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Enhanced Checkmark for selected
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(color)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    // Base background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            isSelected ?
                                LinearGradient(
                                    colors: [
                                        color.opacity(0.2),
                                        color.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.08),
                                        Color.white.opacity(0.04)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                    
                    // Border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ?
                                LinearGradient(
                                    colors: [color, color.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: isSelected ? 2.5 : 1
                        )
                }
                .shadow(
                    color: isSelected ? color.opacity(0.5) : Color.black.opacity(0.1),
                    radius: isSelected ? 15 : 5,
                    x: 0,
                    y: isSelected ? 8 : 2
                )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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

struct AchievementPopupView: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack {
            ForEach(achievements) { achievement in
                HStack(spacing: 15) {
                    Image(systemName: achievement.icon)
                        .font(.title)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Achievement Unlocked!")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text(achievement.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("+\(achievement.xpReward) XP")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.9))
                        .shadow(color: .yellow.opacity(0.5), radius: 10)
                )
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top, 60)
    }
}
