import SwiftUI

struct ContentView: View {
    
    var username: String
    @StateObject private var flashcardViewModel = FlashcardViewModel()
    @StateObject var interstitialAdsManager = InterstitialAdsManager()
    @State private var isLoadedAds: Bool
    @State private var backgroundColor: Color = .white  // Arka plan rengi
    @State private var showMessage = false
    @State private var messagePosition: [CGPoint] = [
        CGPoint(x: 0.5, y: 0.5) // Dairenin merkezi
    ]
    @State private var currentMessage: String = "Correct!"  // Veya "Yanlış"
    @State private var showCorrectMessage: Bool = false // Doğru cevap için
    @State private var showWrongMessage: Bool = false // Yanlış cevap için
    @State private var highScores: [UserScore] = [] // Yüksek skorları tutacak değişken
    @State private var highestUserScore: Int = 0
    
    let originalBackgroundColor: Color = .white  // Orijinal arka plan rengi
    
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
            VStack {
                HStack {
                            Text("\(username)")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            
                            Spacer().frame(width: 20) // Arada boşluk bırakmak için Spacer ekledim
                            
                            // Skor Bilgisi
                            Text("Score: \(flashcardViewModel.correctAnswersCount)")
                                .font(.headline)
                                .padding()
                                .background(backgroundColor)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            
                            // En Yüksek Skor Bilgisi
                            Text("Record: \(highestUserScore)")
                        .font(.subheadline)
                                .padding()
                                .background(.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.top, 70)
                        .padding(.horizontal) // HStack'in etrafında yatay padding
            

                
                
                
                // Oyun bitti durumunda "Oyun Bitti" ve yüksek skorlar gösterimi
                if flashcardViewModel.gameOver {
                    VStack {
                        // Oyun Bitti animasyonu
                        Text("Game Over!")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        
                        // Yüksek Skorlar Listesini ekliyoruz
                        VStack {
                            Text("Highest Scores")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                            
                            ForEach(highScores.prefix(3)) { userScore in
                                HStack {
                                    Text(userScore.username)
                                    Spacer()
                                    Text("\(userScore.score)")
                                }
                                .padding()
                            }
                        }
                        .padding(.top, 30)
                        
                        // Oyun Yenileme ve Kalp Yenileme butonları
                        HStack(spacing: 40) {
                            Button(action: {
                                flashcardViewModel.restartGame()
                            }) {
                                Image(systemName: "goforward")
                                    .font(.system(size: 44))
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .accessibilityLabel("Restart Game")
                            
                            Button(action: {
                                    loadAd()
                                    flashcardViewModel.restoreHearts()
                                    showAd()}
                            ) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .accessibilityLabel("Refill Hearts")
                        }
                    }
                    .padding()
                }
                else {
                    if flashcardViewModel.loadingNewQuestions {
                        VStack {
                            Text("New questions are loading...")
                                .font(.headline)
                                .padding()
                        }
                        .onAppear {
                            showMessage = true
                        }
                    }
                    else if flashcardViewModel.currentQuestions.isEmpty {
                        Text("Loading...")
                            .font(.title)
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
                                Text(flashcard.question)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .padding(.top,20)
                                    .transition(.scale)
                                    .animation(.easeInOut(duration: 0.5))
                                
                                VStack(spacing: 10) {
                                    ForEach(flashcard.choices, id: \.self) { choice in
                                        Button(action: {
                                            flashcardViewModel.checkAnswer(choice, for: flashcard)
                                        }) {
                                            Text(choice)
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
                                    HStack{
                                        HStack(spacing: Double(200/flashcard.point)) {  // Adjust the spacing if needed
                                                    ForEach(0..<flashcard.point) { _ in
                                                        Star().frame(width: Double(200/flashcard.point), height: Double(200/flashcard.point))
                                                    }
                                                }
                                    }
                                    
                                }
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
            .background(backgroundColor)
            .edgesIgnoringSafeArea(.all)
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

