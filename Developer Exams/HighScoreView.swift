import SwiftUI

struct HighScoresView: View {
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @State private var highScores: [UserScore] = []
    @State private var chosenMenu: String
    
    init(chosenMenu: String) {
        _chosenMenu = State(initialValue: chosenMenu)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Highest Scores")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(globalViewModel.chosenMenuColor)
                    .padding(.top, 50)
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(highScores.prefix(10)) { userScore in
                            HStack {
                                Text(userScore.username)
                                    .foregroundColor(globalViewModel.chosenMenuColor)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 10)
                                
                                Spacer()
                                
                                Text("\(userScore.score)")
                                    .foregroundColor(globalViewModel.chosenMenuColor)
                                    .font(.headline)
                                    .padding(.trailing, 10)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.top, 30)
                }
                
                Spacer()
                
                Button(action: {
                    globalViewModel.isMenuVisible = true
                }) {
                    Text("Back to Menu")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                        .background(globalViewModel.chosenMenuColor)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 50)
            }
            .onAppear {
                loadHighScores()
            }
        }
    }
    
    func loadHighScores() {
        highScores = ScoreManager.shared.loadScores(for: chosenMenu) // Menüye göre skorlara erişim
    }
}
