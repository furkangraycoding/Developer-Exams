import SwiftUI

struct HighScoresView: View {
    @State private var highScores: [UserScore] = []
    
    var body: some View {
        VStack {
            Text("Highest Scores")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            ForEach(highScores) { userScore in
                HStack {
                    Text(userScore.username)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(userScore.score)")
                }
                .padding()
            }
        }
        .onAppear {
            highScores = ScoreManager.shared.loadScores()
        }
    }
}
