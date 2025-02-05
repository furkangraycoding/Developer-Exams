import SwiftUI

struct ContentView: View {
    
    var username: String = ""
    @StateObject private var flashcardViewModel = FlashcardViewModel()
    @StateObject var interstitialAdsManager = InterstitialAdsManager()
    @State private var isLoadedAds: Bool = false
    @State private var backgroundColor: Color = .black
    @State private var gameOverBackgroundColor: Color = .green
    @State private var showMessage = false
    @State private var messagePosition: [CGPoint] = [
        CGPoint(x: 0.5, y: 0.5)
    ]
    @State private var currentMessage: String = "Correct!"
    @State private var showCorrectMessage: Bool = false
    @State private var showWrongMessage: Bool = false
    @State private var highScores: [UserScore] = []
    @State private var highestUserScore: Int = 0
    @State private var chosenMenu: String = ""
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    let originalBackgroundColor: Color = .black
    
    init(username: String, chosenMenu: String) {
        self.chosenMenu = GlobalViewModel.shared.chosenMenu
        self.username = username
        self.isLoadedAds = false
        _highScores = State(initialValue: ScoreManager.shared.loadScores())
        _highestUserScore = State(initialValue: ScoreManager.shared.loadScores().max(by: { $0.score < $1.score })?.score ?? 0)
    }
    
    func showAd() { interstitialAdsManager.displayInterstitialAd() }
    func loadAd() { interstitialAdsManager.loadInterstitialAd() }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            NavigationView {
                VStack {
                    HStack {
                        Button(action: {
                            globalViewModel.isMenuVisible = true
                        }) {
                            Text("<")
                                .background(.white)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(5)
                                .cornerRadius(10)
                        }
                        .cornerRadius(5)
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white, lineWidth: 12)
                        )
                        .background(.white)
                        .padding(.trailing, 5)
                        
                        Text("\(username)")
                            .font(.headline)
                            .padding()
                            .background(gameOverBackgroundColor)
                            .foregroundColor(backgroundColor)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                        Spacer().frame(width: 5)
                        
                        Text("Score: \(flashcardViewModel.correctAnswersCount)")
                            .font(.headline)
                            .padding()
                            .background(gameOverBackgroundColor)
                            .foregroundColor(backgroundColor)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                        Spacer().frame(width: 5)
                        
                        Text("Best: \(highestUserScore)")
                            .font(.headline)
                            .padding()
                            .background(gameOverBackgroundColor)
                            .foregroundColor(backgroundColor)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    if flashcardViewModel.gameOver {
                        VStack {
                            Text("Game Over!")
                                .font(.title)
                                .foregroundColor(gameOverBackgroundColor)
                                .background(originalBackgroundColor)
                                .fontWeight(.bold)
                                .padding()
                            
                            VStack {
                                Text("Highest Scores")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(gameOverBackgroundColor)
                                    .background(originalBackgroundColor)
                                    .padding()
                                
                                ForEach(highScores.prefix(3)) { userScore in
                                    HStack {
                                        Text(userScore.username)
                                            .foregroundColor(gameOverBackgroundColor)
                                            .background(originalBackgroundColor)
                                        Spacer()
                                        Text("\(userScore.score)")
                                            .foregroundColor(gameOverBackgroundColor)
                                            .background(originalBackgroundColor)
                                    }
                                    .padding(.top, 20)
                                }
                            }
                            .padding(.top, 30)
                            
                            HStack(spacing: 40) {
                                Button(action: {
                                    flashcardViewModel.restartGame()
                                }) {
                                    Image(systemName: "goforward")
                                        .font(.system(size: 50))
                                        .foregroundColor(gameOverBackgroundColor)
                                        .padding()
                                        .background(originalBackgroundColor)
                                        .clipShape(Circle())
                                        .shadow(radius: 5)
                                        .overlay(
                                            Circle()
                                                .stroke(gameOverBackgroundColor, lineWidth: 4)
                                        )
                                }
                                .accessibilityLabel("Restart Game")
                                
                                Button(action: {
                                    loadAd()
                                    flashcardViewModel.restoreHearts()
                                    showAd()
                                }) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(gameOverBackgroundColor)
                                        .padding()
                                        .background(originalBackgroundColor)
                                        .clipShape(Circle())
                                        .shadow(radius: 5)
                                        .overlay(
                                            Circle()
                                                .stroke(gameOverBackgroundColor, lineWidth: 4)
                                        )
                                }
                                .accessibilityLabel("Refill Hearts")
                            }
                            .padding(.top, 50)
                        }
                        .padding()
                    } else {
                        if flashcardViewModel.loadingNewQuestions {
                            VStack {
                                Text("New questions are loading...")
                                    .font(.headline)
                                    .foregroundStyle(Color.white)
                                    .padding()
                            }
                            .onAppear {
                                showMessage = true
                            }
                        } else if flashcardViewModel.currentQuestions.isEmpty {
                            Text("Loading...")
                                .font(.title)
                                .foregroundStyle(Color.white)
                                .padding()
                        } else if flashcardViewModel.currentIndex < flashcardViewModel.currentQuestions.count {
                            let flashcard = flashcardViewModel.currentQuestions[flashcardViewModel.currentIndex]
                            
                            VStack {
                                if flashcardViewModel.showingAnswer {
                                    GeometryReader { geometry in
                                        ForEach(0..<messagePosition.count, id: \.self) { index in
                                            Text(currentMessage)
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(
                                                    showCorrectMessage ? .green : (showWrongMessage ? .red : .clear)
                                                )
                                                .position(
                                                    x: geometry.size.width * messagePosition[index].x,
                                                    y: geometry.size.height * messagePosition[index].y
                                                )
                                                .scaleEffect(showMessage ? 3 : 0.7)
                                                .opacity(showMessage ? 1 : 0)
                                                .animation(
                                                    .easeInOut(duration: 0.3)
                                                        .repeatCount(2, autoreverses: true),
                                                    value: showMessage
                                                )
                                        }
                                    }
                                    .onAppear {
                                        if flashcardViewModel.resultMessage == "Correct!" {
                                            showCorrectMessage = true
                                            currentMessage = "Correct!"
                                            backgroundColor = .green.opacity(0.3)
                                        } else {
                                            showWrongMessage = true
                                            currentMessage = "Try again"
                                            backgroundColor = .pink.opacity(0.3)
                                        }
                                        
                                        showMessage = true
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            showMessage = false
                                            showCorrectMessage = false
                                            showWrongMessage = false
                                            backgroundColor = originalBackgroundColor
                                        }
                                    }
                                } else {
                                        ScrollView{
                                            VStack(spacing: 10) {
                                                Text("(\(flashcard.point) points) \n \n\(flashcard.question)")
                                                    .foregroundStyle(Color.white)
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                    .multilineTextAlignment(.center)
                                                    .frame(maxWidth: .infinity)
                                                    .minimumScaleFactor(0.5)
                                                    .padding(.top, 20)
                                                
                                                VStack {
                                                    ForEach(flashcard.choices, id: \.self) { choice in
                                                        Button(action: {
                                                            flashcardViewModel.checkAnswer(choice, for: flashcard)
                                                        }) {
                                                            Text(choice)
                                                                .font(.headline)
                                                                .padding()
                                                                .frame(maxWidth: .infinity)
                                                                .minimumScaleFactor(0.5)
                                                                .background(Color.blue)
                                                                .foregroundColor(.white)
                                                                .cornerRadius(10)
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                    }
                                                }
                                                .padding(.top, 40)
                                            }
                                            .padding()
                                        }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    Spacer()
                    
                    if !flashcardViewModel.gameOver {
                        HStack {
                            ForEach(0..<flashcardViewModel.heartsRemaining, id: \.self) { _ in
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 42))
                                    .foregroundColor(.red)
                                    .offset(y: -10)
                            }
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(backgroundColor)
            }
        }
        .onChange(of: flashcardViewModel.gameOver) { newValue in
            if newValue {
                let newScore = UserScore(username: username, score: flashcardViewModel.correctAnswersCount)
                ScoreManager.shared.addNewScore(newScore)
                highScores = ScoreManager.shared.loadScores()
            }
            updateHighestUserScore()
        }
    }
    
    func updateHighestUserScore() {
        if let highestScoreUser = highScores.max(by: { $0.score < $1.score }) {
            highestUserScore = highestScoreUser.score
        }
    }
}
