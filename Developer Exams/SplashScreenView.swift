import SwiftUI
import Combine

struct SplashScreenView: View {
    @State private var displayedText: String = ""
    private let fullText = "Ready to improve your skills!"
    private let typingSpeed: TimeInterval = 0.085
    @State private var timer: Timer.TimerPublisher?
    @State private var index = 0
    
    @State private var navigateToMainScreen = false
    @State private var cancellables: Set<AnyCancellable> = []
    @Binding var isActive : String
    @EnvironmentObject var globalViewModel: GlobalViewModel

    var body: some View {
        ZStack {
            // Green to black gradient background
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.green.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .animation(.linear(duration: 5).repeatForever(autoreverses: true), value: displayedText)
            
            SteadyRandomShapesView()
                .opacity(0.8) // Decreased opacity to avoid overwhelming the main content
                .edgesIgnoringSafeArea(.all)

                        
            VStack {
                Spacer()

                // Logo/Icon Animation
                Image(systemName: "app.fill") // Replace with your own logo
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green) // Set the logo color to green
                    .opacity(navigateToMainScreen ? 0 : 1) // Fade out during transition
                    .offset(y: navigateToMainScreen ? -200 : 0) // Move the logo to the top during transition
                    .animation(.easeOut(duration: 0.5), value: navigateToMainScreen)
                    .padding()

                // Display the typing text
                Text(displayedText)
                    .font(.custom("Courier New", size: 24))
                    .fontWeight(.regular)
                    .foregroundColor(.white) // Text in white for contrast
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(40)
                    .opacity(navigateToMainScreen ? 0 : 1) // Fade out during transition
                    .offset(y: navigateToMainScreen ? -200 : 0) // Move the text to the top during transition
                    .animation(.easeOut(duration: 1), value: navigateToMainScreen)

                Spacer()
            }
        }
        .onAppear {
            startTypingAnimation()
        }
        .onChange(of: navigateToMainScreen) { _ in
            if navigateToMainScreen {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    transitionToMainApp()
                }
            }
        }
    }
    
    // Start the typing animation
    private func startTypingAnimation() {
        // Create the timer manually and use onReceive to track its updates
        timer = Timer.publish(every: typingSpeed, on: .main, in: .common)
        
        // Use onReceive to listen for timer updates and update the displayed text
        timer?
            .autoconnect()
            .sink { _ in
                typeText()
            }
            .store(in: &cancellables)
    }
    
    // This will type out the text one character at a time
    private func typeText() {
        if index < fullText.count {
            let character = fullText[fullText.index(fullText.startIndex, offsetBy: index)]
            displayedText.append(character)
            index += 1
        } else {
            // Once all the text is typed, stop the timer
            timer?.connect().cancel()
            // Trigger the navigation to the next screen after delay
            navigateToMainScreen = true
        }
    }
    
    // Trigger the navigation to the next screen
    private func transitionToMainApp() {
        globalViewModel.isActive = "Login"
    }
}
