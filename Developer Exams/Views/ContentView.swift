import SwiftUI

struct ContentView: View {
    
    var username: String = ""
    @StateObject private var flashcardViewModel = FlashcardViewModel()
    @StateObject var interstitialAdsManager = InterstitialAdsManager()
    @State private var isLoadedAds: Bool = false
    @State private var backgroundColor: Color = .black
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @State private var gameOverBackgroundColor: Color = GlobalViewModel.shared.chosenMenuColor.opacity(0.8)
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
    
    
    let originalBackgroundColor: Color = .black
    
    init(username: String, chosenMenu: String) {
        self.chosenMenu = GlobalViewModel.shared.chosenMenu
        self.username = username
        self.isLoadedAds = false
        _highScores = State(initialValue: ScoreManager.shared.loadScores(for: GlobalViewModel.shared.chosenMenu))
        _highestUserScore = State(initialValue: ScoreManager.shared.loadScores(for: GlobalViewModel.shared.chosenMenu).max(by: { $0.score < $1.score })?.score ?? 0)
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
                            HStack {
                                Image(systemName: "chevron.left") // Sol ok ikonu
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                            .padding(10)
                            .background(gameOverBackgroundColor)
                            .cornerRadius(15) // Daha yuvarlak köşeler
                            .shadow(radius: 5) // Hafif gölge ekleyerek butonun daha belirgin olmasını sağlıyoruz
                        }
                        .padding(.leading, 5) // Kenara biraz daha yakın

                        Text("\(username)")
                            .font(.headline)
                            .padding()
                            .background(gameOverBackgroundColor)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                        Spacer().frame(width: 5)
                        
                        Text("Score: \(flashcardViewModel.correctAnswersCount)")
                            .font(.headline)
                            .padding()
                            .background(gameOverBackgroundColor)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                        Spacer().frame(width: 5)
                        
                        Text("Best: \(highestUserScore)")
                            .font(.headline)
                            .padding()
                            .background(gameOverBackgroundColor)
                            .foregroundColor(.black)
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
                                if flashcardViewModel.showingAnswer  {
                                    GeometryReader { geometry in
                                        ForEach(0..<messagePosition.count, id: \.self) { index in
                                            Text(currentMessage)
                                                .font(.title)
                                                .fontWeight(.semibold)
                                                .foregroundColor(
                                                    showCorrectMessage ? gameOverBackgroundColor.opacity(1) : (showWrongMessage ? .red.opacity(0.9) : .clear)
                                                )
                                                .italic(showWrongMessage)
                                                .position(
                                                    x: geometry.size.width * messagePosition[index].x,
                                                    y: geometry.size.height * messagePosition[index].y
                                                )
                                                .scaleEffect(showMessage ? (showCorrectMessage ? 2.7 :2.7) : 2.7) // Correct mesajı büyük olur
                                                .opacity(showMessage ? 1 : 0) // Mesaj görünür
                                                // Correct durumda: önce dönüp sonra büyüme animasyonu
                                                .rotationEffect(showCorrectMessage && showMessage ? .degrees(360) : .degrees(0)) // Dönme animasyonu
                                                .animation(
                                                    showCorrectMessage
                                                    ? .easeInOut(duration: 0.9).repeatCount(1, autoreverses: true)
                                                    : .easeInOut(duration: 0.6).repeatCount(1, autoreverses: true),
                                                    value: showMessage
                                                )
                                                // Try Again durumu: sadece büyüme ve kaybolma animasyonu
                                                .scaleEffect(showWrongMessage && showMessage ? 1 : 1)
                                                .rotationEffect(.degrees(0)) // Try again durumunda dönme yok
                                        }
                                    }
                                    .onAppear {
                                        if flashcardViewModel.resultMessage == "Correct!" {
                                            showCorrectMessage = true
                                            currentMessage = "Correct!"
                                            backgroundColor = gameOverBackgroundColor.opacity(0.4)
                                            showWrongMessage = false // Try Again durumunu sıfırlıyoruz
                                        } else {
                                            showWrongMessage = true
                                            currentMessage = "Try again"
                                            backgroundColor = .black
                                            showCorrectMessage = false // Correct durumunu sıfırlıyoruz
                                        }
                                        
                                        showMessage = true
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                            showMessage = false
                                            showCorrectMessage = false
                                            showWrongMessage = false
                                            backgroundColor = originalBackgroundColor
                                        }
                                    }

                                    
                                }else {
                                        ScrollView{
                                            VStack(spacing: 10) {
                                                Text("(\(flashcard.point) points) \n \n\(flashcard.question)")
                                                    .foregroundStyle(Color.white)
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                    .multilineTextAlignment(.leading)
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
                                                                .multilineTextAlignment(.center)
                                                                .background(gameOverBackgroundColor)
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
                                    .foregroundColor(gameOverBackgroundColor)
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
                let newScore = UserScore(username: username, score: flashcardViewModel.correctAnswersCount, scoreMenu: GlobalViewModel.shared.chosenMenu)
                ScoreManager.shared.addNewScore(newScore)
                highScores = ScoreManager.shared.loadScores(for: GlobalViewModel.shared.chosenMenu)
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
