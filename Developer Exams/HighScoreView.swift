import SwiftUI

struct HighScoresView: View {
    @State private var highScores: [UserScore] = []
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            VStack {
                Text("Highest Scores")
                    .font(.title)
                    .background(Color.white)
                    .foregroundColor(.green)
                    .fontWeight(.bold)
                    .padding()
                
                ForEach(highScores) { userScore in
                    HStack {
                        Text(userScore.username)
                            .foregroundColor(.green)
                        Spacer()
                        Text("\(userScore.score)")
                            .foregroundColor(.green)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            highScores = ScoreManager.shared.loadScores()
        }
    }
}
