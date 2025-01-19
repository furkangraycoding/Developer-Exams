import SwiftUI
import Combine

struct SplashScreenView: View {
    @State private var displayedText: String = ""
    private let fullText = "Welcome to the Developer Quiz App!\nReady to improve your skills?"
    private let typingSpeed: TimeInterval = 0.075
    @State private var timer: Timer.TimerPublisher?
    @State private var index = 0
    
    @State private var navigateToMainScreen = false
    @State private var cancellables: Set<AnyCancellable> = []
    @Binding var isActive : String
    @EnvironmentObject var globalViewModel: GlobalViewModel

    var body: some View {
        NavigationView {
            ZStack {
                // Set the entire screen's background color to black
                Color.black
                    .edgesIgnoringSafeArea(.all) // Make sure this fills the entire screen

                VStack {
                    Spacer()
                    
                    // Display the typing text
                    Text(displayedText)
                        .font(.custom("Courier New", size: 24))
                        .fontWeight(.regular)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(40)
                        .animation(.easeIn(duration: typingSpeed), value: displayedText)
                    
                    Spacer()
                }
            }
            .onAppear {
                startTypingAnimation()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Optional: for more consistent behavior across iOS versions
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
            displayedText.append(".")
            sleep(UInt32(0.25))
            displayedText.append(".")
            sleep(UInt32(0.25))
            displayedText.append(".")
            sleep(UInt32(0.25))
            // Trigger the navigation to the next screen
            transitionToMainApp()
        }
    }
    
    // Trigger the navigation to the next screen
    private func transitionToMainApp() {
        navigateToMainScreen = true
        globalViewModel.isActive = "Login"
    }
}
