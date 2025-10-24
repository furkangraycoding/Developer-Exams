import SwiftUI
import Combine

class FlashcardViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    @Published var currentIndex: Int = 0
    @Published var showingAnswer: Bool = false
    @Published var resultMessage: String? = nil
    @Published var currentQuestions: [Flashcard] = []
    @Published var correctAnswersCount: Int = 0
    @Published var loadingNewQuestions: Bool = false
    @Published var heartsRemaining: Int = 5 // Kalp simgeleri için
    @Published var gameOver: Bool = false // Oyun bitişi durumu
    @Published var chosenMenu: String = ""
    
    private var allFlashcards: [Flashcard] = []
    private var wrongQuestions: [Flashcard] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Don't load flashcards here - they will be loaded in setupGame()
        // This prevents loading the wrong language on initialization
    }
    
    func updateMenu(globalViewModel: GlobalViewModel) {
        // Access the global chosenMenu
        self.chosenMenu = globalViewModel.chosenMenu
        print("Updated chosenMenu: \(self.chosenMenu)")
    }
    
    func loadFlashcards(chosenMenu : String) {
        print("🔍 Attempting to load flashcards for language: '\(chosenMenu)'")
        
        guard let url = Bundle.main.url(forResource: chosenMenu, withExtension: "json") else {
            print("❌ JSON file not found for: '\(chosenMenu)'")
            print("📂 Looking for file: '\(chosenMenu).json'")
            return
        }
        
        print("✅ Found JSON file at: \(url.lastPathComponent)")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Flashcard].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("❌ Failed to load JSON data: \(error.localizedDescription)")
                }
            }, receiveValue: { flashcards in
                print("✅ Successfully loaded \(flashcards.count) flashcards for '\(chosenMenu)'")
                if let firstQuestion = flashcards.first {
                    print("📝 First question: \(firstQuestion.question)")
                }
                self.allFlashcards = flashcards
                self.loadNewQuestions()
            })
            .store(in: &cancellables)
    }
    
    func loadNewQuestions() {
        guard !gameOver, allFlashcards.count >= 50 else {
            print("Not enough flashcards available or game is over.")
            return
        }
        
        loadingNewQuestions = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // 0.5 saniye bekle
            var newQuestions = Array(self.allFlashcards.shuffled().prefix(50))
            
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
    
    func getQuestionPoint(for flashcard: Flashcard) -> Int {
        return flashcard.point
    }
    
    func checkAnswer(_ choice: String, for flashcard: Flashcard) {
        let isCorrect = choice == flashcard.answer
        resultMessage = isCorrect ? "Correct!" : "Try Again"
        showingAnswer = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut) {
                self.showingAnswer = false
                
                if isCorrect {
                    self.correctAnswersCount += flashcard.point
                } else {
                    self.heartsRemaining -= 1 // Kalp eksilt
                    self.wrongQuestions.append(flashcard)
                    
                    if self.heartsRemaining <= 0 {
                        self.heartsRemaining = 0
                        self.gameOver = true // Oyun bitişi
                    }
                }
                
                self.currentIndex += 1
                
                if self.currentIndex >= self.currentQuestions.count && !self.gameOver {
                    if !self.allFlashcards.isEmpty || !self.wrongQuestions.isEmpty {
                        self.loadNewQuestions()
                    } else {
                        self.resultMessage = nil
                        self.gameOver = true // Oyun bitişi, tüm sorular tamamlandığında
                    }
                }
            }
        }
    }
    
    func restartGame() {
        withAnimation(.easeInOut) {
            correctAnswersCount = 0
            heartsRemaining = 5
            gameOver = false
        }
        loadNewQuestions()
    }

    // Kalpleri yenileme fonksiyonu
    func restoreHearts() {
        heartsRemaining = 5
        gameOver = false // Oyunu devam ettir
    }
}
