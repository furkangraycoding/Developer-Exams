import SwiftUI
import Combine

class QuizViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var showingAnswer: Bool = false
    @Published var resultMessage: String? = nil
    @Published var currentQuestions: [QuizQuestion] = []
    @Published var correctAnswersCount: Int = 0
    @Published var loadingNewQuestions: Bool = false
    @Published var heartsRemaining: Int = 5
    @Published var gameOver: Bool = false
    @Published var selectedLanguage: String = ""
    @Published var showHint: Bool = false
    @Published var hintText: String = ""
    @Published var selectedDifficulty: DifficultyLevel?
    @Published var correctStreak: Int = 0
    @Published var gameStartTime: Date?
    @Published var totalQuestions: Int = 0
    @Published var newAchievements: [Achievement] = []
    @Published var showAchievement: Bool = false
    @Published var comboMultiplier: Int = 1
    
    private var allQuestions: [QuizQuestion] = []
    private var wrongQuestions: [QuizQuestion] = []
    private var cancellables = Set<AnyCancellable>()
    private let progressManager = ProgressManager.shared
    
    var currentQuestion: QuizQuestion? {
        guard currentIndex < currentQuestions.count else { return nil }
        return currentQuestions[currentIndex]
    }
    
    var progress: Double {
        guard !currentQuestions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(currentQuestions.count)
    }
    
    init() {
        // Empty init
    }
    
    func startGame(language: String, difficulty: DifficultyLevel? = nil) {
        self.selectedLanguage = language
        self.selectedDifficulty = difficulty
        self.gameStartTime = Date()
        self.correctAnswersCount = 0
        self.heartsRemaining = 5
        self.gameOver = false
        self.currentIndex = 0
        self.correctStreak = 0
        self.comboMultiplier = 1
        self.totalQuestions = 0
        
        progressManager.addLanguage(language)
        loadQuestions(for: language)
    }
    
    func loadQuestions(for language: String) {
        guard let url = Bundle.main.url(forResource: language, withExtension: "json") else {
            print("JSON file not found for \(language)")
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("Failed to load data from \(language)")
            return
        }
        
        do {
            let flashcards = try JSONDecoder().decode([Flashcard].self, from: data)
            
            // Convert Flashcard to QuizQuestion
            self.allQuestions = flashcards.map { flashcard in
                QuizQuestion(
                    question: flashcard.question,
                    choices: flashcard.choices,
                    answer: flashcard.answer,
                    point: flashcard.point,
                    hint: nil,
                    explanation: nil,
                    difficulty: self.determineDifficulty(for: flashcard.point),
                    category: language
                )
            }
            
            DispatchQueue.main.async {
                self.prepareQuestions()
            }
        } catch {
            print("Failed to decode JSON data: \(error.localizedDescription)")
        }
    }
    
    private func determineDifficulty(for points: Int) -> DifficultyLevel {
        switch points {
        case 1...3: return .easy
        case 4...6: return .medium
        case 7...9: return .hard
        default: return .expert
        }
    }
    
    private func prepareQuestions() {
        guard !gameOver, allQuestions.count >= 20 else {
            print("Not enough questions or game is over.")
            return
        }
        
        loadingNewQuestions = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            var filteredQuestions = self.allQuestions
            
            // Filter by difficulty if selected
            if let difficulty = self.selectedDifficulty {
                filteredQuestions = filteredQuestions.filter { $0.difficulty == difficulty }
            }
            
            var newQuestions = Array(filteredQuestions.shuffled().prefix(20))
            
            // Shuffle choices for each question
            for index in newQuestions.indices {
                newQuestions[index].shuffleChoices()
            }
            
            // Add previously wrong questions
            if !self.wrongQuestions.isEmpty {
                newQuestions.append(contentsOf: self.wrongQuestions)
                self.wrongQuestions.removeAll()
            }
            
            withAnimation(.easeInOut) {
                self.currentQuestions = newQuestions
                self.currentIndex = 0
                self.loadingNewQuestions = false
            }
        }
    }
    
    func checkAnswer(_ choice: String) {
        guard let question = currentQuestion else { return }
        
        let isCorrect = choice == question.answer
        resultMessage = isCorrect ? "Correct!" : "Try Again"
        showingAnswer = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            withAnimation(.easeInOut) {
                self.showingAnswer = false
                
                if isCorrect {
                    self.correctStreak += 1
                    self.totalQuestions += 1
                    
                    // Calculate combo multiplier
                    self.comboMultiplier = min(1 + (self.correctStreak / 5), 5)
                    
                    let basePoints = question.finalPoints()
                    let finalPoints = basePoints * self.comboMultiplier
                    
                    self.correctAnswersCount += finalPoints
                    self.progressManager.recordAnswer(isCorrect: true, points: finalPoints)
                    
                    // Check for perfect round
                    if self.correctStreak == 10 {
                        self.progressManager.recordPerfectRound()
                    }
                } else {
                    self.correctStreak = 0
                    self.comboMultiplier = 1
                    self.heartsRemaining -= 1
                    self.wrongQuestions.append(question)
                    self.progressManager.recordAnswer(isCorrect: false, points: 0)
                    
                    if self.heartsRemaining <= 0 {
                        self.endGame()
                    }
                }
                
                self.currentIndex += 1
                
                if self.currentIndex >= self.currentQuestions.count && !self.gameOver {
                    if !self.allQuestions.isEmpty || !self.wrongQuestions.isEmpty {
                        self.prepareQuestions()
                    } else {
                        self.endGame()
                    }
                }
            }
        }
    }
    
    func useHint() {
        guard let question = currentQuestion, !showHint else { return }
        
        progressManager.useHint()
        
        // Generate a hint by eliminating wrong answers
        let wrongChoices = question.choices.filter { $0 != question.answer }
        if wrongChoices.count >= 2 {
            let eliminated = wrongChoices.prefix(2).joined(separator: ", ")
            hintText = "These are wrong: \(eliminated)"
        } else if let hint = question.hint {
            hintText = hint
        } else {
            hintText = "The answer starts with '\(question.answer.prefix(1))'"
        }
        
        withAnimation {
            showHint = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                self.showHint = false
            }
        }
    }
    
    func endGame() {
        gameOver = true
        
        // Check for achievements
        if let startTime = gameStartTime {
            let timeElapsed = Date().timeIntervalSince(startTime)
            
            // Check centurion achievement
            if correctAnswersCount >= 100 {
                progressManager.userProgress.checkAchievements()
            }
            
            // Check speed demon achievement
            if totalQuestions >= 20 && timeElapsed <= 120 {
                progressManager.userProgress.checkAchievements()
            }
        }
        
        progressManager.incrementGamesPlayed()
        
        // Check for new achievements
        newAchievements = progressManager.checkForNewAchievements()
        if !newAchievements.isEmpty {
            showAchievement = true
        }
    }
    
    func restartGame() {
        withAnimation(.easeInOut) {
            correctAnswersCount = 0
            heartsRemaining = 5
            gameOver = false
            correctStreak = 0
            comboMultiplier = 1
            totalQuestions = 0
            gameStartTime = Date()
        }
        prepareQuestions()
    }
    
    func restoreHearts() {
        heartsRemaining = 5
        gameOver = false
    }
}
