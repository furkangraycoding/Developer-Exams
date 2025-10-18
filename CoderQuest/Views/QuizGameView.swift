import SwiftUI

struct QuizGameView: View {
    let language: String
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = QuizViewModel()
    @State private var showDifficultySelector = true
    @State private var selectedAnswer: String?
    @State private var animateCorrect = false
    @State private var animateWrong = false
    @State private var confettiCounter = 0
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.05, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if showDifficultySelector {
                DifficultySelector(language: language) { difficulty in
                    viewModel.startGame(language: language, difficulty: difficulty)
                    withAnimation {
                        showDifficultySelector = false
                    }
                }
            } else if viewModel.gameOver {
                GameOverView(viewModel: viewModel) {
                    dismiss()
                }
            } else {
                mainGameView
            }
            
            // Achievement popup
            if viewModel.showAchievement && !viewModel.newAchievements.isEmpty {
                AchievementPopup(achievement: viewModel.newAchievements.first!)
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                viewModel.showAchievement = false
                            }
                        }
                    }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var mainGameView: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Progress bar
            progressBarView
            
            Spacer()
            
            if viewModel.loadingNewQuestions {
                loadingView
            } else if let question = viewModel.currentQuestion {
                questionView(question)
            }
            
            Spacer()
            
            // Lives and combo
            bottomInfoView
        }
        .padding()
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                )
            }
            
            Spacer()
            
            // Score
            HStack(spacing: 5) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(viewModel.correctAnswersCount)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.yellow.opacity(0.2), .orange.opacity(0.2)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            )
            
            // Hint button
            Button(action: { viewModel.useHint() }) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
        }
    }
    
    private var progressBarView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.cyan, .blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: geometry.size.width * viewModel.progress)
                    .animation(.spring(), value: viewModel.progress)
            }
        }
        .frame(height: 8)
        .padding(.vertical, 15)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.cyan)
            
            Text("Loading questions...")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private func questionView(_ question: QuizQuestion) -> some View {
        VStack(spacing: 30) {
            // Question card
            VStack(spacing: 15) {
                // Difficulty badge
                HStack {
                    DifficultyBadge(difficulty: question.difficulty)
                    
                    Spacer()
                    
                    Text("\(question.point) pts")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.yellow.opacity(0.2))
                        )
                }
                
                Text(question.question)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 2)
                    )
            )
            .shadow(color: .cyan.opacity(0.2), radius: 15)
            
            // Hint display
            if viewModel.showHint {
                HStack(spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    
                    Text(viewModel.hintText)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.2))
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            // Answer buttons
            if viewModel.showingAnswer {
                answerFeedbackView
            } else {
                answersGrid(question)
            }
        }
    }
    
    private func answersGrid(_ question: QuizQuestion) -> some View {
        VStack(spacing: 12) {
            ForEach(question.choices, id: \.self) { choice in
                AnswerButton(
                    text: choice,
                    isSelected: selectedAnswer == choice
                ) {
                    selectedAnswer = choice
                    viewModel.checkAnswer(choice)
                }
            }
        }
    }
    
    private var answerFeedbackView: some View {
        VStack(spacing: 20) {
            ZStack {
                if viewModel.resultMessage == "Correct!" {
                    LottieView(animation: "confetti")
                        .frame(width: 200, height: 200)
                }
                
                VStack(spacing: 15) {
                    Image(systemName: viewModel.resultMessage == "Correct!" ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(viewModel.resultMessage == "Correct!" ? .green : .red)
                        .scaleEffect(animateCorrect || animateWrong ? 1.2 : 0.5)
                        .opacity(animateCorrect || animateWrong ? 1 : 0)
                    
                    Text(viewModel.resultMessage ?? "")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(viewModel.resultMessage == "Correct!" ? .green : .red)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    if viewModel.resultMessage == "Correct!" {
                        animateCorrect = true
                        confettiCounter += 1
                    } else {
                        animateWrong = true
                    }
                }
            }
            .onDisappear {
                animateCorrect = false
                animateWrong = false
                selectedAnswer = nil
            }
        }
    }
    
    private var bottomInfoView: some View {
        VStack(spacing: 15) {
            // Combo multiplier
            if viewModel.comboMultiplier > 1 {
                HStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    
                    Text("x\(viewModel.comboMultiplier) Combo!")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.2))
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            // Lives
            HStack(spacing: 10) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < viewModel.heartsRemaining ? "heart.fill" : "heart")
                        .font(.system(size: 28))
                        .foregroundColor(index < viewModel.heartsRemaining ? .red : .gray)
                        .scaleEffect(index < viewModel.heartsRemaining ? 1.0 : 0.8)
                        .animation(.spring(), value: viewModel.heartsRemaining)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
}

struct DifficultySelector: View {
    let language: String
    let onSelect: (DifficultyLevel?) -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Select Difficulty")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text(language)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.cyan)
            }
            
            VStack(spacing: 15) {
                DifficultyButton(
                    difficulty: nil,
                    title: "Mixed",
                    description: "All difficulty levels",
                    color: .purple
                ) {
                    onSelect(nil)
                }
                
                ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                    DifficultyButton(
                        difficulty: difficulty,
                        title: difficulty.rawValue,
                        description: descriptionFor(difficulty),
                        color: colorFor(difficulty)
                    ) {
                        onSelect(difficulty)
                    }
                }
            }
            .padding(.horizontal, 30)
        }
    }
    
    private func descriptionFor(_ difficulty: DifficultyLevel) -> String {
        switch difficulty {
        case .easy: return "Great for beginners"
        case .medium: return "For intermediate learners"
        case .hard: return "Challenge yourself"
        case .expert: return "Only for masters"
        }
    }
    
    private func colorFor(_ difficulty: DifficultyLevel) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert: return .red
        }
    }
}

struct DifficultyButton: View {
    let difficulty: DifficultyLevel?
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconName: String {
        guard let difficulty = difficulty else {
            return "shuffle"
        }
        
        switch difficulty {
        case .easy: return "leaf.fill"
        case .medium: return "star.fill"
        case .hard: return "flame.fill"
        case .expert: return "crown.fill"
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: DifficultyLevel
    
    var body: some View {
        Text(difficulty.rawValue.uppercased())
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(colorFor(difficulty))
            )
    }
    
    private func colorFor(_ difficulty: DifficultyLevel) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert: return .red
        }
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isSelected ? Color.cyan.opacity(0.3) : Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(isSelected ? Color.cyan : Color.white.opacity(0.2), lineWidth: 2)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LottieView: View {
    let animation: String
    
    var body: some View {
        // Placeholder for Lottie animation
        // You would integrate lottie-ios here
        Text("")
    }
}

struct QuizGameView_Previews: PreviewProvider {
    static var previews: some View {
        QuizGameView(language: "Swift")
    }
}
