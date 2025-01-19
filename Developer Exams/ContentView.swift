import SwiftUI

struct ContentView: View {
    
    var username: String
    @StateObject private var flashcardViewModel = FlashcardViewModel()
    @StateObject var interstitialAdsManager = InterstitialAdsManager()
    @State private var isLoadedAds: Bool
    @State private var backgroundColor: Color = .black  // Arka plan rengi
    @State private var gameOverBackgroundColor: Color = .green
    @State private var showMessage = false
    @State private var messagePosition: [CGPoint] = [
        CGPoint(x: 0.5, y: 0.5) // Dairenin merkezi
    ]
    @State private var currentMessage: String = "Correct!"  // Veya "Yanlış"
    @State private var showCorrectMessage: Bool = false // Doğru cevap için
    @State private var showWrongMessage: Bool = false // Yanlış cevap için
    @State private var highScores: [UserScore] = [] // Yüksek skorları tutacak değişken
    @State private var highestUserScore: Int = 0
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    let originalBackgroundColor: Color = .black  // Orijinal arka plan rengi
    
    // Yüksek skorları uygulama başlarken yükle
    init(username: String, chosenMenu: String) {
        self.username = username
        self.isLoadedAds = false
        _highScores = State(initialValue: ScoreManager.shared.loadScores())
        _highestUserScore = State(initialValue: ScoreManager.shared.loadScores().max(by: { $0.score < $1.score })?.score ?? 0)
    }
    
    func showAd(){interstitialAdsManager.displayInterstitialAd()}
    func loadAd() {interstitialAdsManager.loadInterstitialAd()}
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            NavigationView{
                VStack {
                    HStack {
                        Button(action: {
                            globalViewModel.isMenuVisible = true;
                            MenuView(isMenuVisible: $globalViewModel.isMenuVisible)})
                            {
                                Text("<")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .padding(5)
                                    .cornerRadius(10)
                            }
                            .cornerRadius(5)
                            .background(.green)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.green, lineWidth: 12) // Apply border with corner radius
                            )
                            .padding(.trailing, 5)
                        Text("\(username)")
                            .font(.headline)
                            .padding()
                            .background(gameOverBackgroundColor)
                            .foregroundColor(backgroundColor)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                        Spacer().frame(width: 8) // Arada boşluk bırakmak için Spacer ekledim
                        
                        // Skor Bilgisi
                        Text("Score: \(flashcardViewModel.correctAnswersCount)")
                            .font(.headline)
                            .padding()
                            .background(gameOverBackgroundColor)
                            .foregroundColor(backgroundColor)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                        Spacer().frame(width: 8)
                        // En Yüksek Skor Bilgisi
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
                    // HStack'in etrafında yatay padding
                    
                    
                    
                    // Oyun bitti durumunda "Oyun Bitti" ve yüksek skorlar gösterimi
                    if flashcardViewModel.gameOver {
                        VStack {
                            // Oyun Bitti animasyonu
                            Text("Game Over!")
                                .font(.title)
                                .foregroundColor(gameOverBackgroundColor)
                                .background(originalBackgroundColor)
                                .fontWeight(.bold)
                                .padding()
                            
                            // Yüksek Skorlar Listesini ekliyoruz
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
                            
                            // Oyun Yenileme ve Kalp Yenileme butonları
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
                                        .overlay( // Add border around the circle
                                            Circle()
                                                .stroke(gameOverBackgroundColor, lineWidth: 4) // Border color and thickness
                                        )
                                }
                                .accessibilityLabel("Restart Game")
                                
                                Button(action: {
                                    loadAd()
                                    flashcardViewModel.restoreHearts()
                                    showAd()}
                                ) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(gameOverBackgroundColor)
                                        .padding()
                                        .background(originalBackgroundColor)
                                        .clipShape(Circle())
                                        .shadow(radius: 5)
                                        .overlay( // Add border around the circle
                                            Circle()
                                                .stroke(gameOverBackgroundColor, lineWidth: 4) // Border color and thickness
                                        )
                                }
                                .accessibilityLabel("Refill Hearts")
                            }
                            .padding(.top, 50)
                        }
                        .padding()
                    }
                    else {
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
                        }
                        else if flashcardViewModel.currentQuestions.isEmpty {
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
                                    VStack(spacing: 10) {
                                        Text(flashcard.question)
                                            .foregroundStyle(Color.white)
                                            .font(.title)
                                            .fontWeight(.semibold)
                                            .padding(.top,20)
                                            .transition(.scale)
                                            .animation(.easeInOut(duration: 0.5))
                                            .padding(.vertical ,5)
                                            .padding(.top, 20)
                                            .padding(.horizontal ,20)
                                        
                                        VStack{
                                            ForEach(flashcard.choices, id: \.self) { choice in
                                                Button(action: {
                                                    flashcardViewModel.checkAnswer(choice, for: flashcard)
                                                }) {
                                                    Text(choice)
                                                        .font(.headline)
                                                        .padding()
                                                        .frame(maxWidth: .infinity)
                                                        .background(Color.blue)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(10)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .transition(.scale)
                                                .animation(.easeInOut(duration: 0.5))
                                            }
                                        }
                                        .padding(.top, 40)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .transition(.scale)
                                    .animation(.easeInOut(duration: 0.5))
                                }
                            }
                            .padding()
                            .animation(.easeInOut)
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
                // Oyun bittiğinde skoru ekle
                let newScore = UserScore(username: username, score: flashcardViewModel.correctAnswersCount)
                ScoreManager.shared.addNewScore(newScore)
                highScores = ScoreManager.shared.loadScores() // Güncellenmiş skorları tekrar yükle
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

