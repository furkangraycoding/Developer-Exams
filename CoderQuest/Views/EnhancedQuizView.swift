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
    var difficulty: DifficultyLevel = .easy
    
    @StateObject private var flashcardViewModel: FlashcardViewModel
    @StateObject var interstitialAdsManager = InterstitialAdsManager()
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @ObservedObject var progressManager = ProgressManager.shared
    
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer?
    @State private var showGameOver = false
    @State private var showVictoryAnimation = false
    @State private var questionsInSession = 0
    @State private var correctInSession = 0
    @State private var sessionStartTime = Date()
    @State private var selectedAnswer: String? = nil
    @State private var showAchievementPopup = false
    
    init(username: String, chosenMenu: String, difficulty: DifficultyLevel) {
        self.username = username
        self.chosenMenu = chosenMenu
        self.difficulty = difficulty
        _flashcardViewModel = StateObject(wrappedValue: FlashcardViewModel())
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, globalViewModel.chosenMenuColor.opacity(0.3)]),
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
                    
                    Spacer()
                    
                    // Timer (if applicable)
                    if let timeLimit = difficulty.timeLimit {
                        HStack(spacing: 5) {
                            Image(systemName: "timer")
                                .font(.subheadline)
                                .foregroundColor(timeRemaining <= 5 ? .red : .white)
                            Text("\(timeRemaining)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(timeRemaining <= 5 ? .red : .white)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(timeRemaining <= 5 ? Color.red.opacity(0.3) : Color.white.opacity(0.2))
                                .shadow(color: timeRemaining <= 5 ? .red.opacity(0.5) : .clear, radius: 5)
                        )
                        .animation(.easeInOut, value: timeRemaining)
                    }
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
                        
                        ForEach(0..<(difficulty.heartCount - flashcardViewModel.heartsRemaining), id: \.self) { _ in
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
                        difficulty: difficulty,
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
                timer?.invalidate()
                recordGameSession()
                
                if !progressManager.recentlyUnlockedAchievements.isEmpty {
                    withAnimation {
                        showAchievementPopup = true
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
        flashcardViewModel.chosenMenu = chosenMenu
        flashcardViewModel.heartsRemaining = difficulty.heartCount
        flashcardViewModel.loadFlashcards(chosenMenu: chosenMenu)
        sessionStartTime = Date()
        
        if let timeLimit = difficulty.timeLimit {
            timeRemaining = timeLimit
            startTimer()
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // Time's up, count as wrong answer
                flashcardViewModel.heartsRemaining -= 1
                if flashcardViewModel.heartsRemaining <= 0 {
                    flashcardViewModel.gameOver = true
                } else {
                    flashcardViewModel.currentIndex += 1
                    if let timeLimit = difficulty.timeLimit {
                        timeRemaining = timeLimit
                    }
                }
            }
        }
    }
    
    func handleAnswer(_ answer: String, for flashcard: Flashcard) {
        selectedAnswer = answer
        timer?.invalidate()
        
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
                    let multipliedPoints = Int(Double(flashcard.point) * difficulty.pointMultiplier)
                    flashcardViewModel.correctAnswersCount += multipliedPoints
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
                
                if let timeLimit = difficulty.timeLimit {
                    timeRemaining = timeLimit
                    startTimer()
                }
            }
        }
    }
    
    func recordGameSession() {
        let timePlayed = Date().timeIntervalSince(sessionStartTime)
        let isPerfect = correctInSession == questionsInSession && questionsInSession > 0
        
        progressManager.recordGameSession(
            language: chosenMenu,
            score: flashcardViewModel.correctAnswersCount,
            questionsAnswered: questionsInSession,
            correctAnswers: correctInSession,
            difficulty: difficulty,
            timePlayed: timePlayed,
            isPerfect: isPerfect
        )
    }
    
    func restartGame() {
        flashcardViewModel.restartGame()
        questionsInSession = 0
        correctInSession = 0
        sessionStartTime = Date()
        
        if let timeLimit = difficulty.timeLimit {
            timeRemaining = timeLimit
            startTimer()
        }
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Points Badge
                HStack {
                    Spacer()
                    Text("+\(flashcard.point) pts")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(color.opacity(0.6))
                                .shadow(color: color.opacity(0.4), radius: 5)
                        )
                }
                
                // Question
                Text(flashcard.question)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .shadow(color: color.opacity(0.2), radius: 10)
                    )
                
                // Choices
                VStack(spacing: 15) {
                    ForEach(flashcard.choices, id: \.self) { choice in
                        ChoiceButton(
                            text: choice,
                            color: color,
                            isSelected: selectedAnswer == choice
                        ) {
                            onAnswer(choice)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct ChoiceButton: View {
    let text: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(color)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? color.opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 8)
            )
        }
        .buttonStyle(ScaleButtonStyle())
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
    let difficulty: DifficultyLevel
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
                    
                    VStack {
                        Text(difficulty.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(color)
                        Text("Difficulty")
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
